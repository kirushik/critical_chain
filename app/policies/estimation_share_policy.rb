class EstimationSharePolicy < ApplicationPolicy
  def index?
    estimation_policy.manage_shares?
  end

  def create?
    estimation_policy.manage_shares?
  end

  def destroy?
    estimation_policy.manage_shares?
  end

  def transfer_ownership?
    record.estimation.user_id == user.id
  end

  private

  def estimation_policy
    @estimation_policy ||= EstimationPolicy.new(user, record.estimation)
  end
end
