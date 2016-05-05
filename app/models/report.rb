class Report < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :time_period

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Id", "Time Period", "Seller Name/Total", "Name", "Value"]
      all.each do |report|
        if report.user_id == -1
          user_name = 'Total'
        elsif report.user.nil?
          user_name = 'Deleted'
        else
          user_name = report.user.name
        end
        csv << [report.id, report.time_period.nil? ? 'Deleted':report.time_period.name, user_name, report.name, report.value]
      end
    end
  end

end
