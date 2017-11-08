class Csv::ProductMonthlySummaryDecorator
  def initialize(row, company, custom_field_names)
    @row = row
    @company = company
    @custom_field_names = custom_field_names
  end

  def product
    row[:product]['name'] rescue nil
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
    end.join('; ')
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
    deal_custom_field = deal_custom_fields.find{ |u| u['field_label'].downcase == name.to_s.gsub('_', ' ') }
    
    if deal_custom_field
      field_name = deal_custom_field['field_type'].to_s + deal_custom_field['field_index'].to_s
      row[:custom_fields][field_name] 
    end
  end

  private

  attr_reader :row, :company, :custom_field_names

  def deal_custom_fields
    @_deal_custom_fields ||= custom_field_names
  end

  def format_currency(budget)
    ActiveSupport::NumberHelper.number_to_currency(budget, precision: 0)
  end

  def parse_time(time)
    (time ? time.strftime('%m/%d/%Y') : '')
  end
end
