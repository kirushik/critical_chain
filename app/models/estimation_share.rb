# == Schema Information
#
# Table name: estimation_shares
#
#  id                  :integer          not null, primary key
#  estimation_id       :integer          not null
#  shared_with_user_id :integer
#  shared_with_email   :string
#  last_accessed_at    :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_estimation_shares_on_estimation_and_email  (estimation_id,shared_with_email) UNIQUE
#  index_estimation_shares_on_estimation_and_user   (estimation_id,shared_with_user_id) UNIQUE
#  index_estimation_shares_on_estimation_id         (estimation_id)
#  index_estimation_shares_on_shared_with_email     (shared_with_email)
#  index_estimation_shares_on_shared_with_user_id   (shared_with_user_id)
#

class EstimationShare < ActiveRecord::Base
  belongs_to :estimation
  belongs_to :shared_with_user, class_name: 'User', optional: true

  before_validation :normalize_email

  validate :has_user_or_email
  validate :email_format_if_present
  validate :cannot_share_with_owner
  validate :unique_share_per_estimation

  scope :for_user, ->(user) {
    where(shared_with_user: user).or(where(shared_with_email: user.email&.downcase))
  }
  scope :pending, -> { where(shared_with_user_id: nil).where.not(shared_with_email: nil) }
  scope :active, -> { where.not(shared_with_user_id: nil) }

  def pending?
    shared_with_user_id.nil? && shared_with_email.present?
  end

  def active?
    shared_with_user_id.present?
  end

  def display_email
    shared_with_user&.email || shared_with_email
  end

  def touch_last_accessed
    update_column(:last_accessed_at, Time.current)
  end

  # Convert a pending email share to an active user share
  def activate_for_user!(user)
    return false if active?
    return false unless user.email&.downcase == shared_with_email&.downcase

    update!(shared_with_user: user, shared_with_email: nil)
  end

  # Class method to convert all pending shares for a user
  def self.activate_pending_shares_for_user(user)
    return if user.email.blank?

    pending.where(shared_with_email: user.email.downcase).find_each do |share|
      share.activate_for_user!(user)
    end
  end

  private

  def normalize_email
    self.shared_with_email = shared_with_email.to_s.strip.downcase.presence
  end

  def has_user_or_email
    if shared_with_user_id.blank? && shared_with_email.blank?
      errors.add(:base, "Must specify either a user or an email address")
    end
  end

  def email_format_if_present
    if shared_with_email.present? && shared_with_email !~ URI::MailTo::EMAIL_REGEXP
      errors.add(:shared_with_email, "is not a valid email address")
    end
  end

  def cannot_share_with_owner
    return unless estimation_id # Skip validation if estimation not set yet

    owner_email = estimation&.user&.email&.downcase
    return unless owner_email

    if shared_with_user_id == estimation.user_id
      errors.add(:shared_with_user, "cannot share with the estimation owner")
    elsif shared_with_email&.downcase == owner_email
      errors.add(:shared_with_email, "cannot share with the estimation owner")
    end
  end

  def unique_share_per_estimation
    return unless estimation_id

    # Check for duplicate user shares
    if shared_with_user_id.present?
      duplicate = estimation.estimation_shares
        .where(shared_with_user_id: shared_with_user_id)
        .where.not(id: id)

      if duplicate.exists?
        errors.add(:shared_with_user, "already has access to this estimation")
      end
    end

    # Check for duplicate email shares and email matching existing user shares
    if shared_with_email.present?
      normalized_email = shared_with_email.downcase
      # Check email-based duplicates and user-based duplicates in one query
      user_with_email = User.where("LOWER(email) = ?", normalized_email).first

      duplicate = estimation.estimation_shares.where.not(id: id).where(
        "LOWER(shared_with_email) = ? OR shared_with_user_id = ?",
        normalized_email,
        user_with_email&.id
      )

      if duplicate.exists?
        errors.add(:shared_with_email, "already has access to this estimation")
      end
    end
  end
end
