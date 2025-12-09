class EstimationPolicy < ApplicationPolicy
  def show?
    owner? || record.shared_with?(user)
  end

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def manage_shares?
    owner?
  end

  private

  def owner?
    record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.left_joins(:estimation_shares)
           .where(
             "estimations.user_id = :user_id OR " \
             "estimation_shares.shared_with_user_id = :user_id OR " \
             "LOWER(estimation_shares.shared_with_email) = :email",
             user_id: user.id,
             email: user.email&.downcase
           )
           .distinct
    end
  end
end
