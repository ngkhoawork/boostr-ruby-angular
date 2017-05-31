class ActivitySummary::UserService < ActivitySummary::BaseService
  def perform
    { user_activities: user_activity_reports, total_activity_report: total_activity_report }
  end

  def perform_csv_service
    Csv::ActivitySummary::UserService.new(
      users,
      activity_summary_user_csv_options
    ).perform
  end

  private

  def activity_summary_user_csv_options
    {
      company: company,
      start_date: start_date,
      end_date: end_date,
      total: total_activity_report
    }
  end

  def user_activity_reports
    users.reduce([]) do |activity_report, user|
      user_activities = grouped_by_activity_types_for(user)
        .map { |activity| { user_id: user.id, username: user.name, activity.name => activity.count } }
        .reduce({}, :merge)

      user_activities = { user_id: user.id, username: user.name } if user_activities.empty?

      user_activities[:total] = user_activities.values[2..-1].reduce(:+) || 0

      activity_report << user_activities
    end
  end

  def total_activity_report
    total_activities = grouped_by_activity_types_for(users.map(&:id))
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

  def all_active_sales_users
    company.teams.reduce([]) do |all_members, team|
      all_members << team.all_sales_reps.select(&:is_active)
    end
  end

  def all_team_sales_reps
    @_all_team_sales_reps ||=
      if params[:team_id] == 'all'
        all_active_sales_users.flatten.uniq.sort_by(&:first_name)
      else
        team.all_sales_reps.select(&:is_active).sort_by(&:first_name).uniq
      end
  end

  def team
    @_team ||= company.teams.find(params[:team_id])
  end

  def user_type
    @_user_type ||= params[:user_type].to_i
  end

  def users
    @_users ||= params[:user_type].present? ? by_user_type : without_default_and_fake_type
  end

  def by_user_type
    all_team_sales_reps.select { |u| u.user_type.eql? user_type }
  end

  def without_default_and_fake_type
    all_team_sales_reps.reject { |u| [FAKE_USER, DEFAULT].include?(u.user_type) }
  end
end
