class ActivitySummary::BaseService
  def initialize(user, options = {})
    @user = user
    @params = options.fetch(:params)
  end

  private

  attr_reader :user, :params

  def company
    @_company ||= user.company
  end

  def team
    @_team ||= company.teams.find(params[:team_id])
  end

  def time_period
    @_time_period ||= company.time_periods.find(params[:time_period_id])
  end

  def start_date
    @_start_date ||= (params[:start_date] ? Date.parse(params[:start_date]) : (Time.now.end_of_day - 30.days))
  end

  def end_date
    @_end_date ||= (params[:end_date] ? Date.parse(params[:end_date]).end_of_day : Time.now.end_of_day)
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
end
