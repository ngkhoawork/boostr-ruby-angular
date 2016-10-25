class Api::ReportsController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json { 
        render json: { user_activities: user_activity_report, total_activity_report: total_activity_report }
      }
      format.csv { 
        send_data activity_csv_report, filename: "reports-#{Date.today}.csv"
      }
    end
  end

  private

  def user_activity_report
    data = company.users.by_user_type(SELLER).joins('left join activities on activities.user_id=users.id')
    .where("happened_at >= ? and happened_at <= ?", time_period.start_date, time_period.end_date)
    .select("users.id, concat(users.first_name, ' ', users.last_name) as fullname, activities.activity_type_name, count(activities) as count")
    .order('users.id')
    .group("users.id, fullname, activities.activity_type_name")
    .collect { |user| { user_id: user.id, username: user.fullname, "#{user.activity_type_name}": user.count } }

    data = data.group_by { |e| e[:user_id] }.values.map {|e| e.reduce({}, :merge)}
    user_activities = data.each do |user_activity|
      user_activity[:total] = user_activity.values[2..-1].reduce(:+)
    end
  end

  def total_activity_report
    total_activities = Activity.joins("left join activity_types on activities.activity_type_id=activity_types.id")
    .where("user_id in (?) and happened_at >= ? and happened_at <= ?", company.users.by_user_type(SELLER).ids, time_period.start_date, time_period.end_date)
    .select("activity_types.name, count(activities.id) as count")
    .group("activity_types.name").collect { |activity| { "#{activity.name}": activity.count } }

    total_activities = total_activities.reduce({}, :merge)
    total_activities[:total] = total_activities.values.reduce(:+)
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
          count = company.activities.where('happened_at >= ? and happened_at <= ? and activity_type_name = ?', period.start_date, period.end_date, type.name).count
          line << count
        end
        count = company.activities.where('happened_at >= ? and happened_at <= ?', period.start_date, period.end_date).count
        line << count
        csv << line
      end
    end
  end

  def xto_csv(company)
    CSV.generate do |csv|
      header = []
      header << "Time Period"
      header << "Name"
      company.activity_types.each do |a|
        header << a.name
      end
      header << "Total"
      csv << header
      company.time_periods.order(:name).each do |t|
        company.users.order(:first_name).each do |u|
          line = [t.name]
          line << u.name
          company.activity_types.each do |a|
            r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, u.id, a.name).first
            line << (r.nil? ? 0:r.value)
          end
          r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, u.id, 'Total').first
          line << (r.nil? ? 0:r.value)
          csv << line
        end
        line = [t.name]
        line << 'Total'
        company.activity_types.each do |a|
          r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, -1, a.name).first
          line << (r.nil? ? 0:r.value)
        end
        r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, -1, 'Total').first
        line << (r.nil? ? 0:r.value)
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
