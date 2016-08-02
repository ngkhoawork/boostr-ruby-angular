class DealLog < ActiveRecord::Base
  # acts_as_paranoid
  belongs_to :deal

  scope :for_time_period, -> (start_date, end_date) { where('deal_logs.created_at <= ? AND deal_logs.created_at >= ?', end_date, start_date) }
  scope :positive, -> () { where('deal_logs.budget_change > 0') }
end
