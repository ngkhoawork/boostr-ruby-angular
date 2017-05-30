class ActivitySummary::UserService < ActivitySummary::BaseService
  def perform
    { user_activities: user_activity_reports, total_activity_report: total_activity_report }
  end

  private

  def user_activity_reports
    all_team_sales_reps.reduce([]) do |activity_report, user|
      user_activities = grouped_by_activity_types_for(user)
        .map { |activity| { user_id: user.id, username: user.name, activity.name => activity.count } }
        .reduce({}, :merge)

      user_activities = { user_id: user.id, username: user.name } if user_activities.empty?

      user_activities[:total] = user_activities.values[2..-1].reduce(:+) || 0

      activity_report << user_activities
    end
  end

  def total_activity_report
    total_activities = grouped_by_activity_types_for(all_team_sales_reps.map(&:id))
      .map { |activity| { activity.name => activity.count } }

    total_activities = total_activities.reduce({}, :merge)
    total_activities[:total] = total_activities.values.reduce(:+) || 0
    total_activities
  end

  def grouped_by_activity_types_for(user)
    company
      .activities
      .with_activity_types
      .for_time_period(start_date, end_date)
      .by_user(user)
      .group_by_activity_types_name
  end
end
