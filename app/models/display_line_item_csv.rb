class DisplayLineItemCsv
  include ActiveModel::Validations

  validates :line_number, :start_date, :end_date, :product_name,
  :quantity, :budget, :company_id, presence: true
  validates :line_number, :quantity, :budget, :budget_delivered,
  :quantity_delivered, :quantity_delivered_3p, numericality: true

  validates :io, presence: { message: 'or TempIo not found' }

  validate :io_exchange_rate_presence

  attr_accessor(:external_io_number,
    :line_number, :ad_server, :start_date, :end_date,
    :product_name, :quantity, :price, :pricing_type,
    :budget, :budget_delivered, :quantity_delivered,
    :quantity_delivered_3p, :company_id)

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    return self.errors.full_messages unless self.valid?
    if io && display_line_item
      display_line_item.update(
        line_number: line_number,
        ad_server: ad_server,
        start_date: start_date,
        end_date: end_date,
        product: product,
        quantity: quantity,
        price: price,
        pricing_type: pricing_type,
        budget: convert_currency(budget),
        budget_loc: budget_loc,
        budget_delivered: convert_currency(budget_delivered),
        budget_delivered_loc: budget_delivered_loc,
        budget_remaining: convert_currency(budget_remaining),
        budget_remaining_loc: budget_remaining_loc,
        quantity_delivered: quantity_delivered,
        quantity_remaining: quantity_remaining,
        quantity_delivered_3p: quantity_delivered_3p,
      )
    end
  end

  private

  def display_line_item
    @_display_line_item ||= io.display_line_items.find_by_line_number(line_number)
    @_display_line_item ||= io.display_line_items.new
  end

  def convert_currency(value)
    value.to_f / exchange_rate
  end

  def io
    @_io ||= Io.find_by(company_id: company_id, external_io_number: external_io_number)
    @_io ||= TempIo.find_by(company_id: company_id, external_io_number: external_io_number)
  end

  def product
    @_product ||= Product.find_by(company_id: company_id, name: product_name)
  end

  def budget_loc
    budget
  end

  def budget_delivered_loc
    budget_delivered
  end

  def budget_remaining
    budget.to_f - budget_delivered.to_f
  end

  def budget_remaining_loc
    budget_loc.to_f - budget_delivered_loc.to_f
  end

  def quantity_remaining
    quantity.to_f - quantity_delivered.to_f
  end

  def exchange_rate
    @_exchange_rate ||= io.exchange_rate
  end

  def io_exchange_rate_presence
    if io && !(io.exchange_rate)
      errors.add(:budget, "has no exchange rate for #{io.curr_cd} found at #{io.created_at.strftime("%m/%d/%Y")}")
    end
  end

  def persisted?
    false
  end
end
