class PmpMember < ActiveRecord::Base
  belongs_to :pmp, required: true
  belongs_to :user, required: true

  validates :share, :from_date, :to_date, presence: true

  after_save do
    update_revenue_fact if share_changed? || from_date_changed? || to_date_changed?
  end

  after_destroy do
    update_revenue_fact if share > 0
  end

  def update_revenue_fact
    Forecast::PmpRevenueCalcTriggerService.new(pmp, 'user', { users: [user] }).perform
  end
end