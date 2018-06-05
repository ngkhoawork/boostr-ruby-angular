class Csv::ActivePmpItem
  include ActiveModel::Validations
  include Csv::Pmp

  attr_accessor :deal_id,
                :name,
                :full_name,
                :ssp,
                :pmp_type,
                :product_name,
                :start_date,
                :end_date,
                :budget,
                :delivered,
                :custom_fields_required,
                :custom_fields_optional,
                :company

  PMP_LABELS = {"Guaranteed" => "guaranteed", "Non-Guaranteed" => "non_guaranteed", "Always On" => "always_on"}.freeze

  validates :deal_id, :name, :ssp, :pmp_type, :product_name, :delivered, presence: true

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
    raise custom_fields_required[:raises].join(', ') unless custom_fields_required[:raises].blank?

    if custom_fields_params.present?
      with_custom_fields_params = active_pmp_item_params.merge!(custom_field: CustomField.new(custom_fields_params))
    end
    pmp_item = PmpItem.find_by(ssp_deal_id: deal_id)
    if pmp_item.present?
      pmp_item.update_attributes(active_pmp_item_params)
      if pmp_item.custom_field.present?
        pmp_item.custom_field.update_attributes(custom_fields_params)
      else
        pmp_item.custom_field = CustomField.new(custom_fields_params)
        pmp_item.save
      end
    else
      PmpItem.new(with_custom_fields_params).save!
    end
  end

  def custom_fields_params
    results = fetch_results(custom_fields_optional)
    results.merge!(fetch_results(custom_fields_required.except!(:raises)))
    results
  end

  def fetch_results(collection)
    collection&.map{ |cfk, cfv| [custom_field_name(cfk), custom_field_name_convert(cfk,cfv)] }.to_h.symbolize_keys
  end

  def custom_field_name(key)
    return if cf_name(key).blank?
    [cf_name(key)&.column_type,cf_name(key)&.column_index].join
  end

  def custom_field_name_convert(key,cfv)
    return if cf_name(key).blank?
    if cf_name(key)&.column_type.eql?('datetime')
      check_and_format_date(cfv)
    else
      cfv
    end
  end

  def cf_name(key)
    @_cf_name ||= CustomFieldName.active
                      .for_model('PmpItem')
                      &.find_by('lower(field_label) = ?', key.to_s.gsub('_',' '))
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
    ::Product.find_by(name: product_name).id
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
