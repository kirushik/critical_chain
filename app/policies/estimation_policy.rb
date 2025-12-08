class EstimationPolicy < ApplicationPolicy
  def show?
    record.user_id == user.id || record.can_view?(user)
  end

  def create?
    record.user_id == user.id
  end

  def update?
    record.user_id == user.id || record.can_edit?(user)
  end

  def destroy?
    record.user_id == user.id
  end

  def manage_shares?
    record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      owned = scope.where(user_id: user.id)
      shared = scope.joins(:estimation_shares).where(estimation_shares: { shared_with_email: user.email })
      owned.or(shared).distinct
    end
  end
end