class Io < ActiveRecord::Base
  belongs_to :advertiser, class_name: 'Client', foreign_key: 'advertiser_id'
  belongs_to :agency, class_name: 'Client', foreign_key: 'agency_id'
  belongs_to :deal, class_name: 'Deal', foreign_key: 'io_number'
  belongs_to :company
  has_many :io_members, dependent: :destroy
  has_many :content_fees, dependent: :destroy

  after_update do
    reset_content_fees if (start_date_changed? || end_date_changed?)
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

  def days
    (end_date - start_date + 1).to_i
  end

  def months
    (start_date..end_date).map { |d| [d.year, d.month] }.uniq
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

  def update_total_budget
    update_attributes(budget: content_fees.sum(:budget))
  end

  def merge_recursively(a, b)
    a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
  end
  def as_json(options = {})
    super(merge_recursively(options,
        include: {
            advertiser: { name: {} },
            agency: { name: {} }
        }
      )
    )
  end
end
