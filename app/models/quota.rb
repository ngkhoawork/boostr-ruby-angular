class Quota < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :time_period
  belongs_to :company

  scope :for_time_period, -> (start_date, end_date) { where('quota.start_date <= ? AND quota.end_date >= ?', end_date, start_date) }

  before_save :set_dates

  validates :user_id, :time_period_id, :company_id, presence: true

  def as_json(options={})
    super(options.merge(methods: [:user_name]))
  end

  def user_name
    user.name if user
  end

  def set_dates
    self.start_date ||= self.time_period.try(:start_date)
    self.end_date ||= self.time_period.try(:end_date)
  end
end
