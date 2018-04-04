class Csv::ProductMonthlySummaryDecorator
  def initialize(row, company, custom_field_names)
    @row = row
    @company = company
    @custom_field_names = custom_field_names
  end

  def product
    row[:product]['level0']['name'] rescue nil
  end

  def record_type
    row[:record_type]
  end

  def record_id
    row[:record_id]
  end

  def name
    row[:name]
  end

  def advertiser
    row[:advertiser]['name'] rescue nil
  end
  
  def agency
    row[:agency]['name'] rescue nil
  end
  
  def team_member
    row[:members].map do |member|
      "#{member[:name]} #{member[:share]}%"
    end.join(', ')
  end

  def holding_co
    row[:holding_company]
  end

  def stage
    row[:stage]['name'] rescue nil
  end

  def %
    row[:stage]['probability'] rescue nil
  end

  def budget
    row[:budget_loc]
  end

  def currency
    row[:currency]['curr_cd'] rescue nil
  end

  def budget_usd
    format_currency(row[:budget])
  end

  def weighted_amt
    format_currency(row[:weighted_budget])
  end

  def start_date
    parse_time(row[:start_date])
  end

  def end_date
    parse_time(row[:end_date])
  end

  def created_date
    parse_time(row[:created_at])
  end

  def closed_date
    parse_time(row[:closed_at])
  end

  def deal_type
    row[:type]
  end

  def deal_source
    row[:source]
  end

  def method_missing(name)
    check_product_options(name) || check_custom_fields(name)
  end

  private

  attr_reader :row, :company, :custom_field_names

  def check_product_options(name)
    if company.product_options_enabled && company.product_option1_enabled && name.eql?(product_option1)
      row[:product]&.[]('level1')&.[]('name')
    elsif company.product_options_enabled && company.product_option2_enabled && name.eql?(product_option2)
      row[:product]&.[]('level2')&.[]('name')
    end
  end

  def check_custom_fields(name)
    deal_custom_field = deal_product_custom_fields.find{ |u| name.eql?(parameterize(u['field_label'])) }
    
    if deal_custom_field
      field_name = deal_custom_field['field_type'].to_s + deal_custom_field['field_index'].to_s
      row[:custom_fields][field_name] 
    end
  end

  def parameterize(name)
    Csv::BaseService.parameterize(name).to_sym
  end

  def product_option1
    parameterize(company.product_option1)
  end

  def product_option2
    parameterize(company.product_option2)
  end

  def deal_product_custom_fields
    @_deal_product_custom_fields ||= custom_field_names
  end

  def format_currency(budget)
    ActiveSupport::NumberHelper.number_to_currency(budget, precision: 0)
  end

  def parse_time(time)
    (time ? time.strftime('%m/%d/%Y') : '')
  end
end
