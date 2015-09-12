class Quota < ActiveRecord::Base
  belongs_to :user
  belongs_to :time_period
  belongs_to :company

  scope :for_time_period, -> (time_period_id) { where(time_period_id: time_period_id) if time_period_id.present? }

  def as_json(options={})
    super(options.merge(methods: [:user_name]))
  end

  def user_name
    user.full_name if user
  end
end
