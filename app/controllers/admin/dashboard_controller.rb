module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users: User.count,
        users_last_7_days: User.where('created_at > ?', 7.days.ago).count,
        users_last_30_days: User.where('created_at > ?', 30.days.ago).count,
        total_estimations: Estimation.count,
        estimations_last_7_days: Estimation.where('created_at > ?', 7.days.ago).count,
        estimations_last_30_days: Estimation.where('created_at > ?', 30.days.ago).count,
        active_users_last_7_days: User.where('last_sign_in_at > ?', 7.days.ago).count,
        active_users_last_30_days: User.where('last_sign_in_at > ?', 30.days.ago).count,
        total_estimation_items: EstimationItem.count,
        total_shares: EstimationShare.count,
        banned_users: User.where.not(banned_at: nil).count
      }
    end
  end
end
