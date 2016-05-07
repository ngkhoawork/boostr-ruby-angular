class Report < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  def self.to_csv(company)
    CSV.generate do |csv|
      csv << ["Time Period", "Seller Name/Total", "Name", "Value"]
      company.time_periods.order(:name).each do |t|
        company.activity_types.each do |a|
          r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, -1, a.name).first
          csv << [t.name, 'Total', a.name, r.nil? ? 0:r.value]
        end
        r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, -1, 'Total').first
        csv << [t.name, 'Total', 'Total', r.nil? ? 0:r.value]
        company.users.order(:first_name).each do |u|
          company.activity_types.each do |a|
            r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, u.id, a.name).first
            csv << [t.name, u.name, a.name, r.nil? ? 0:r.value]
          end
          r = all.where("time_period_id = ? and user_id = ? and name = ?", t.id, u.id, 'Total').first
          csv << [t.name, u.name, 'Total', r.nil? ? 0:r.value]
        end
      end
    end
  end
end
