class DisplayLineItem < ActiveRecord::Base
  belongs_to :io
  belongs_to :product

  before_save :set_alert

  def set_alert(should_save=false)
    if !budget.nil? && !budget_remaining.nil?
      if budget > 0 && start_date < DateTime.now && DateTime.now < end_date
        self.daily_run_rate = ((budget - budget_remaining)/(DateTime.now.to_date-start_date.to_date+1))
        if self.daily_run_rate != 0
          self.num_days_til_out_of_budget = budget_remaining/(self.daily_run_rate)
          self.balance = ((end_date.to_date-DateTime.now.to_date+1)-self.num_days_til_out_of_budget)*(self.daily_run_rate)
        else
          self.num_days_til_out_of_budget = 0
          self.balance = 0
        end
      else
        self.daily_run_rate = 0
        self.num_days_til_out_of_budget = 0
        self.balance = 0
      end
      self.last_alert_at = DateTime.now
    end
    self.save if should_save
  end

  def merge_recursively(a, b)
    a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end
  def as_json(options = {})
    super(merge_recursively(options,
        include: {
          product: {}
        }
      )
    )
  end

end
