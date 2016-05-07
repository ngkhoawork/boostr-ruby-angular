class Report < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  def self.to_csv(company)
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

end
