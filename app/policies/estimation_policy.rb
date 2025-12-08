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
      # Get IDs of owned estimations
      owned_ids = scope.where(user_id: user.id).pluck(:id)

      # Get IDs of shared estimations (both active user shares and pending email shares)
      shared_ids = scope.joins(:estimation_shares)
        .where(
          "estimation_shares.shared_with_user_id = :user_id OR estimation_shares.shared_with_email = :email",
          user_id: user.id,
          email: user.email
        )
        .pluck(:id)

      # Return combined results using IDs to avoid structural incompatibility with .or()
      scope.where(id: (owned_ids + shared_ids).uniq)
    end
  end
end
