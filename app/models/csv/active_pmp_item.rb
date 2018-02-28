class Csv::ActivePmpItem
  include ActiveModel::Validations
  include Csv::Pmp

  attr_accessor :deal_id,
                :name,
                :ssp,
                :pmp_type,
                :product,
                :start_date,
                :end_date,
                :budget,
                :delivered

  PMP_LABELS = {"Guaranteed" => "guaranteed", "Non-Guaranteed" => "non_guaranteed", "Always On" => "always_on"}.freeze

  validates :deal_id, :name, :ssp, :pmp_type, :product, :delivered, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def perform
    record
  end

  private

  def record
    pmp_item = PmpItem.find_by(ssp_deal_id: deal_id)
    if pmp_item.present?
      pmp_item.update_attributes(active_pmp_item_params)
    else
      PmpItem.new(active_pmp_item_params).save!
    end
  end

  def check_ssp
    ::Ssp.find_by(name: ssp).id
  rescue
    raise_error("Ssp")
  end

  def check_pmp_type
    PMP_TYPES[PMP_LABELS[pmp_type].to_sym]
  rescue
    raise_error("Pmp type")
  end

  def check_product
    ::Product.find_by(name: product).id
  rescue
    raise_error("Product")
  end

  def check_budget
    budget.present? ? budget.to_d : check_delivered
  rescue
    raise_invalid_field("budget")
  end

  def check_delivered
    delivered.to_d
  rescue
    raise_invalid_field("delivered")
  end

  def check_pmp_id
    ::Pmp.find_by(name: name).id
  rescue
    raise_invalid_field("Name")
  end

  def active_pmp_item_params
    {
      ssp_deal_id: deal_id,
      pmp_id: check_pmp_id,
      ssp_id: check_ssp,
      pmp_type: check_pmp_type,
      product_id: check_product,
      start_date: check_and_format_date(start_date),
      end_date: check_and_format_date(end_date),
      budget: check_budget,
      budget_delivered: check_delivered,
      budget_remaining: 0,
      budget_loc: check_budget,
      budget_delivered_loc: check_delivered,
      budget_remaining_loc: 0,
      skip_callback: true
    }
  end

end
