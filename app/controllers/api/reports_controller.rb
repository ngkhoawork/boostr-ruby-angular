class Api::ReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json { 
        render json: activity_report
      }
      format.csv { 
        send_data ordered_reports.to_csv(company), filename: "reports-#{Date.today}.csv" 
      }
    end
  end

  private

  def report
    @report ||= company.reports.find(params[:id])
  end

  def activity_report
    data = company.users.by_user_type(SELLER).joins('left join activities on activities.user_id=users.id').where("happened_at >= ? and happened_at <= ?", time_period.start_date, time_period.end_date).select("users.id, concat(users.first_name, ' ', users.last_name) as fullname, activities.activity_type_name, count(activities.id) as count").order('users.id').group("users.id, fullname, activities.activity_type_name").collect { |user| { user_id: user.id, username: user.fullname, "#{user.activity_type_name}": user.count } }
    data.group_by { |e| e[:user_id] }.values.map {|e| e.reduce({}, :merge)}
  end

  def time_period
    @time_period ||= company.time_periods.find(params[:time_period_id])
  end

  def reports
    company.reports
  end

  def company
    @company ||= current_user.company
  end

  def ordered_reports
    company.reports.order(:time_period_id, :user_id, :name, :value)
  end
end
