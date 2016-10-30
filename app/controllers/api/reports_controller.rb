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
    company.users.by_user_type(SELLER).order(:first_name).each do |user|
      user_activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
      .where("user_id = ? and happened_at >= ? and happened_at <= ?", user.id, time_period.start_date, time_period.end_date)
      .select("activity_types.name, count(activities.id) as count")
      .group("activity_types.name").collect { |activity| { username: user.name, "#{activity.name}": activity.count } }
      .reduce({}, :merge)

      if user_activities.empty?
        user_activities = {username: user.name}
      end
      user_activities[:total] = user_activities.values[1..-1].reduce(:+) || 0
      activity_report << user_activities
    end

    activity_report
  end

  def total_activity_report
    total_activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
    .where("user_id in (?) and happened_at >= ? and happened_at <= ?", company.users.by_user_type(SELLER).ids, time_period.start_date, time_period.end_date)
    .select("activity_types.name, count(activities.id) as count")
    .group("activity_types.name").collect { |activity| { "#{activity.name}": activity.count } }

    total_activities = total_activities.reduce({}, :merge)
    total_activities[:total] = total_activities.values.reduce(:+) || 0
    total_activities
  end

  def activity_csv_report
    CSV.generate do |csv|
      header = []
      header << "Time Period"
      header << "Name"
      company.activity_types.each do |a|
        header << a.name
      end
      header << "Total"
      csv << header

      company.time_periods.order(:name).each do |period|
        company.users.by_user_type(SELLER).order(:first_name).each do |user|
          line = [period.name]
          line << user.name
          company.activity_types.each do |type|
            count = user.activities.where('happened_at >= ? and happened_at <= ? and activity_type_name = ?', period.start_date, period.end_date, type.name).count
            line << count
          end

          total = user.activities.where('happened_at >= ? and happened_at <= ?', period.start_date, period.end_date).count
          line << total
          csv << line
        end

        line = [period.name]
        line << 'Total'
        company.activity_types.each do |type|
          count = company.activities.where('happened_at >= ? and happened_at <= ? and activity_type_name = ? and user_id in (?)', period.start_date, period.end_date, type.name, company.users.by_user_type(SELLER).ids).count
          line << count
        end
        count = company.activities.where('happened_at >= ? and happened_at <= ? and user_id in (?)', period.start_date, period.end_date, company.users.by_user_type(SELLER).ids).count
        line << count
        csv << line
      end
    end
  end

  def time_period
    @time_period ||= company.time_periods.find(params[:time_period_id])
  end

  def company
    @company ||= current_user.company
  end
end
