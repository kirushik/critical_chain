# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  email               :string           default(""), not null
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :string
#  last_sign_in_ip     :string
#  created_at          :datetime
#  updated_at          :datetime
#  provider            :string
#  uid                 :string
#  banned_at           :datetime
#  banned_by_email     :string
#
# Indexes
#
#  index_users_on_banned_at  (banned_at)
#  index_users_on_email      (email) UNIQUE
#  index_users_on_provider   (provider)
#  index_users_on_uid        (uid)
#

class User < ActiveRecord::Base
  devise :omniauthable, :rememberable, :trackable, :omniauth_providers => [:google_oauth2]

  has_many :estimations
  has_many :estimation_shares, foreign_key: :shared_with_user_id, dependent: :destroy

  after_create :activate_pending_shares
  after_update :activate_pending_shares, if: :saved_change_to_email?

  def self.from_omniauth auth, current_user = nil
    return current_user if current_user

    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.email = auth.info.email
      # user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
    end

    # Activate any pending shares for this user
    user.activate_pending_shares

    user
  end

  def activate_pending_shares
    EstimationShare.activate_pending_shares_for_user(self)
  end

  def self.admin_emails
    @admin_emails ||= ENV.fetch('ADMIN_EMAILS', '').split(',').map(&:strip).map(&:downcase)
  end

  def admin?
    return false if email.blank?
    self.class.admin_emails.include?(email.downcase)
  end

  def banned?
    banned_at.present?
  end

  def ban!(admin_user)
    raise ArgumentError, 'admin_user is required' if admin_user.nil?
    raise ArgumentError, 'admin_user must have an email' if admin_user.email.blank?

    update!(
      banned_at: Time.current,
      banned_by_email: admin_user.email
    )
  end

  def unban!
    update!(
      banned_at: nil,
      banned_by_email: nil
    )
  end

  # Devise hook: Prevent banned users from authenticating
  def active_for_authentication?
    super && !banned?
  end

  # Custom message for banned users
  def inactive_message
    banned? ? :banned : super
  end
end
