module Admin
  class DashboardController < BaseController
    def index
      @stats = Rails.cache.fetch("admin_dashboard_stats", expires_in: 5.minutes) do
        seven_days_ago = 7.days.ago
        thirty_days_ago = 30.days.ago

        user_counts = User.connection.select_one(
          User.sanitize_sql_array([<<-SQL.squish, seven_days_ago, thirty_days_ago, seven_days_ago, thirty_days_ago])
            SELECT
              COUNT(*) AS total_users,
              COUNT(CASE WHEN created_at > ? THEN 1 END) AS users_last_7_days,
              COUNT(CASE WHEN created_at > ? THEN 1 END) AS users_last_30_days,
              COUNT(CASE WHEN last_sign_in_at > ? THEN 1 END) AS active_users_last_7_days,
              COUNT(CASE WHEN last_sign_in_at > ? THEN 1 END) AS active_users_last_30_days,
              COUNT(CASE WHEN banned_at IS NOT NULL THEN 1 END) AS banned_users
            FROM users
          SQL
        )

        estimation_counts = Estimation.connection.select_one(
          Estimation.sanitize_sql_array([<<-SQL.squish, seven_days_ago, thirty_days_ago])
            SELECT
              COUNT(*) AS total_estimations,
              COUNT(CASE WHEN created_at > ? THEN 1 END) AS estimations_last_7_days,
              COUNT(CASE WHEN created_at > ? THEN 1 END) AS estimations_last_30_days
            FROM estimations
          SQL
        )

        {
          total_users: user_counts["total_users"].to_i,
          users_last_7_days: user_counts["users_last_7_days"].to_i,
          users_last_30_days: user_counts["users_last_30_days"].to_i,
          total_estimations: estimation_counts["total_estimations"].to_i,
          estimations_last_7_days: estimation_counts["estimations_last_7_days"].to_i,
          estimations_last_30_days: estimation_counts["estimations_last_30_days"].to_i,
          active_users_last_7_days: user_counts["active_users_last_7_days"].to_i,
          active_users_last_30_days: user_counts["active_users_last_30_days"].to_i,
          total_estimation_items: EstimationItem.count,
          total_shares: EstimationShare.count,
          banned_users: user_counts["banned_users"].to_i
        }
      end
    end
  end
end
