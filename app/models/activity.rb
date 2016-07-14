class Activity < ActiveRecord::Base

  belongs_to :company
  belongs_to :user
  belongs_to :client
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :deal
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'
  belongs_to :updator, class_name: 'User', foreign_key: 'updated_by'
  belongs_to :activity_type

  has_and_belongs_to_many :contacts

  validates :company_id, presence: true

  after_create do
    if !deal_id.nil?
      deal = company.deals.find(deal_id)
      deal.update_attribute(:activity_updated_at, happened_at)
    elsif !client_id.nil?
      client = company.clients.find(client_id)
      client.update_attribute(:activity_updated_at, happened_at)
    end
    user = company.users.find(user_id)
    time_period = company.time_periods.where("start_date <= ? and end_date >= ?", happened_at, happened_at).first

    if !time_period.nil?
      report = user.reports.find_or_initialize_by(name: activity_type.name, company_id: company.id, time_period_id: time_period.id)
      report.update_attributes(value: report.value.nil? ? 1:(report.value+1))

      report_total = user.reports.find_or_initialize_by(name: 'Total', company_id: company.id, time_period_id: time_period.id)
      report_total.update_attributes(value: user.reports.where("time_period_id = ? and company_id = ? and name != ?", time_period.id, company.id, 'Total').sum(:value))

      report_co = company.reports.find_or_initialize_by(name: activity_type.name, company_id: company.id, time_period_id: time_period.id, user_id: -1)
      report_co.update_attributes(value: company.reports.where("name = ? and time_period_id =? and user_id != ?", activity_type.name, time_period.id, -1).sum(:value))

      report_co_total = company.reports.find_or_initialize_by(name: 'Total', company_id: company.id, time_period_id: time_period.id, user_id: -1)
      report_co_total.update_attributes(value: company.reports.where("name = ? and time_period_id =? and user_id != ?", 'Total', time_period.id, -1).sum(:value))
    end
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        :client => {},
        :agency => {},
        :deal => {
          :include => [
            :stage,
            :advertiser
          ]
        },
        :contacts => {},
        :creator => {}
      }
    ))
  end
end
