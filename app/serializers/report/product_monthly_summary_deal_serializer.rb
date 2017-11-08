class Report::ProductMonthlySummarySerializer < ActiveModel::Serializer
  attributes  :id, :name, :advertiser, :agency, :holding_company, :budget, :budget_loc, :stage,
              :start_date, :end_date, :created_at, :closed_at, :type, :source,
              :custom_fields, :currency

  def record_type
    'Deal'
  end

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def holding_company
    if object.agency.present?
      object.agency.holding_company.name rescue nil
    end
  end

  def stage
    object.stage.serializable_hash(only: [:name, :probability]) rescue nil
  end

  def budget
    object.budget.to_i
  end

  def budget_loc
    object.budget_loc.to_i
  end

  def currency
    object.currency.serializable_hash(only: [:curr_symbol, :curr_cd])
  end

  def type
    object.get_option_value_from_raw_fields(@options[:deal_custom_fields], 'Deal Type')
  end

  def source
    object.get_option_value_from_raw_fields(@options[:deal_custom_fields], 'Deal Source')
  end

  def custom_fields
    custom_fields = {}

    company.deal_custom_field_names.map do |field|
      cf_value = object.deal_custom_field.send(field.field_name) rescue nil

      custom_fields[field.id.to_s] = cf_value
    end

    custom_fields
  end

  private

  def company
    @_company ||= object.company
  end
end
