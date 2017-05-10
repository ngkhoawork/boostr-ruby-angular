class Api::ReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json { 
        render json: { user_activities: user_activity_reports, total_activity_report: total_activity_report }
      }
      format.csv { 
        send_data activity_csv_report, filename: "reports-#{Date.today}.csv"
      }
    end
  end

  private

  def user_activity_reports
    activity_report = []
    all_team_sales_reps.each do |user|
      
      user_activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
      .for_time_period(start_date, end_date)
      .where("user_id = ?", user.id)
      .select("activity_types.name, count(activities.id) as count")
      .group("activity_types.name").collect { |activity| { user_id: user.id, username: user.name, "#{activity.name}": activity.count } }
      .reduce({}, :merge)

      if user_activities.empty?
        user_activities = {user_id: user.id, username: user.name}
      end
      user_activities[:total] = user_activities.values[2..-1].reduce(:+) || 0
      activity_report << user_activities
    end

    activity_report
  end

  def total_activity_report
    total_activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
    .for_time_period(start_date, end_date)
    .where("user_id in (?)", all_team_sales_reps.collect{|row| row.id})
    .select("activity_types.name, count(activities.id) as count")
    .group("activity_types.name").collect { |activity| { "#{activity.name}": activity.count } }

    total_activities = total_activities.reduce({}, :merge)
    total_activities[:total] = total_activities.values.reduce(:+) || 0
    total_activities
  end

  def activity_csv_report
    CSV.generate do |csv|
      header = []
      header << "Name"
      company.activity_types.each do |a|
        header << a.name
      end
      header << "Total"
      csv << header
      activity_types = company.activity_types.to_a
      all_team_sales_reps.each do |user|
        line = [user.name]
        activity_types.each do |type|
          count = user.activities.where('happened_at >= ? and happened_at <= ? and activity_type_name = ?', start_date, end_date, type.name).count
          line << count
        end

        total = user.activities.where('happened_at >= ? and happened_at <= ?', start_date, end_date).count
        line << total
        csv << line
      end
      line = ['Total']
      company.activity_types.each do |type|
        count = company.activities.where('happened_at >= ? and happened_at <= ? and activity_type_name = ? and user_id in (?)', start_date, end_date, type.name, all_team_sales_reps.collect{|row| row.id}).count
        line << count
      end
      count = company.activities.where('happened_at >= ? and happened_at <= ? and user_id in (?)', start_date, end_date, all_team_sales_reps.collect{|row| row.id}).count
      line << count
      csv << line
    end
  end

  def time_period
    @time_period ||= company.time_periods.find(params[:time_period_id])
  end

  def start_date
    @start_date ||= (params[:start_date] ? Date.parse(params[:start_date]) : (Time.now.end_of_day - 30.days))
  end

  def end_date
    @end_date ||= (params[:end_date] ? Date.parse(params[:end_date]).end_of_day : Time.now.end_of_day)
  end

  def team
    @team ||= company.teams.find(params[:team_id])
  end

  def all_team_sales_reps
    if params[:team_id] == 'all'
      return @all_team_sales_reps if @all_team_sales_reps
      @all_team_members = []
      company.teams.each do |team_row|
        @all_team_members += team_row.all_sales_reps.reject {|row| row.is_active == false }
      end
      @all_team_members = @all_team_members.sort_by {|obj| obj.first_name}.uniq
    else
      @all_team_sales_reps ||= team.all_sales_reps.reject {|row| row.is_active == false }.sort_by {|obj| obj.first_name}.uniq
    end
  end

  def company
    @company ||= current_user.company
  end
end
