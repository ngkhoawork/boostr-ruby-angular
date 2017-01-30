class Io < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :deal
  belongs_to :company
  has_one :currency, class_name: 'Currency', primary_key: 'curr_cd', foreign_key: 'curr_cd'
  has_many :io_members, dependent: :destroy
  has_many :users, dependent: :destroy, through: :io_members
  has_many :content_fees, dependent: :destroy
  has_many :content_fee_product_budgets, dependent: :destroy, through: :content_fees
  has_many :display_line_items, dependent: :destroy
  has_many :display_line_item_budgets, through: :display_line_items
  has_many :print_items, dependent: :destroy

  validates :name, :budget, :advertiser_id, :start_date, :end_date , presence: true
  validate :active_exchange_rate
  scope :for_time_period, -> (start_date, end_date) { where('ios.start_date <= ? AND ios.end_date >= ?', end_date, start_date) }

  after_update do
    if (start_date_changed? || end_date_changed?)
      reset_member_effective_dates
    end
  end

  def reset_content_fees
    # This only happens if start_date or end_date has changed on the Deal and thus it has already be touched
    ActiveRecord::Base.no_touching do
      content_fees.each do |content_fee|
        content_fee.content_fee_product_budgets.destroy_all
        content_fee.create_content_fee_product_budgets
      end
    end
  end

  def reset_member_effective_dates
    io_members.each do |io_member|
      date_changed = false
      puts start_date_was
      puts io_member.from_date
      if start_date_was == io_member.from_date
        io_member.from_date = start_date
        date_changed = true
        puts io_member.to_json
      end
      if end_date_was == io_member.to_date
        io_member.to_date = end_date
        date_changed = true
      end

      io_member.save if date_changed
    end
  end

  def days
    (end_date - start_date + 1).to_i
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
  end

  def readable_months
    TimePeriods.new(start_date..end_date).months_with_names(long_names: false)
  end

  def days_per_month
    array = []

    case months.length
      when 0
        array
      when 1
        array << days
      when 2
        array << ((start_date.end_of_month + 1) - start_date).to_i
        array << (end_date - (end_date.beginning_of_month - 1)).to_i
      else
        array << ((start_date.end_of_month + 1) - start_date).to_i
        (months[1..-2] || []).each do |month|
          array << Time.days_in_month(month[1], month[0])
        end
        array << (end_date - (end_date.beginning_of_month - 1)).to_i
    end
    array
  end

  def exchange_rate
    company.exchange_rate_for(currency: self.curr_cd, at_date: (self.created_at || Date.today))
  end

  def active_exchange_rate
    if curr_cd != 'USD'
      unless self.exchange_rate
        errors.add(:curr_cd, "does not have an exchange rate for #{self.curr_cd} at #{self.created_at.strftime("%m/%d/%Y")}")
      end
    end
  end

  def update_total_budget
    new_budget = (content_fees.sum(:budget) + display_line_items.sum(:budget))
    new_budget_loc = (content_fees.sum(:budget_loc) + display_line_items.sum(:budget_loc))
    update_attributes(
      budget: new_budget,
      budget_loc: new_budget_loc
    )
  end

  def effective_revenue_budget(member, start_date, end_date)
    io_member = self.io_members.find_by(user_id: member.id)
    share = io_member.share
    total_budget = 0
    self.content_fees.each do |content_fee|
      content_fee.content_fee_product_budgets.for_time_period(start_date, end_date).each do |content_fee_product_budget|
        total_budget += content_fee_product_budget.daily_budget * effective_days(start_date, end_date, io_member, [content_fee_product_budget]) * (share/100.0)
      end
    end

    self.display_line_items.each do |display_line_item|
      in_budget_days = 0
      in_budget_total = 0
      display_line_item.display_line_item_budgets.each do |display_line_item_budget|
        in_days = effective_days(start_date, end_date, io_member, [display_line_item, display_line_item_budget])
        in_budget_days += in_days
        in_budget_total += display_line_item_budget.daily_budget * in_days * (share/100.0)
      end
      total_budget += in_budget_total + display_line_item.ave_run_rate * (effective_days(start_date, end_date, io_member, [display_line_item]) - in_budget_days) * (share/100.0)
    end
    total_budget
  end

  def effective_days(start_date, end_date, effecter, objects)
    from = [start_date]
    to = [end_date]
    from += objects.collect{ |object| object.start_date }
    to += objects.collect{ |object| object.end_date }

    if effecter.present? && effecter.from_date && effecter.to_date
      from << effecter.from_date
      to << effecter.to_date
    end
    [(to.min.to_date - from.max.to_date) + 1, 0].max.to_f
  end

  def merge_recursively(a, b)
    a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end
  def as_json(options = {})
    super(merge_recursively(options,
        include: {
            currency: { only: :curr_symbol },
            advertiser: { name: {} },
            agency: { name: {} },
            deal: { name: {} }
        }
      )
    )
  end

  def full_json
    self.as_json( include: {
        io_members: {
            methods: [
                :name
            ]
        },
        currency: {},
        content_fees: {
            include: {
                content_fee_product_budgets: {}
            },
            methods: [
                :product
            ]
        },
        display_line_items: {
            methods: [
                :product
            ]
        },
        print_items: {}
      },
      methods: [:readable_months]
    )
  end
end
