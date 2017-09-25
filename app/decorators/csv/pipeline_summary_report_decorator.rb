class Csv::PipelineSummaryReportDecorator
  def initialize(deal, company)
    @deal = deal
    @company = company
  end

  def deal_id
    deal[:id]
  end

  def name
    deal[:name]
  end

  def advertiser
    deal[:advertiser]['name'] rescue nil
  end

  def category
    deal[:category]
  end

  def agency
    deal[:agency]['name'] rescue nil
  end

  def holding_company
    deal[:holding_company]
  end

  def budget_usd
    deal[:budget]
  end

  def budget
    deal[:budget_loc] rescue nil
  end

  def stage
    deal[:stage]['name'] rescue nil
  end

  def %
    deal[:stage]['probability'] rescue nil
  end

  def start_date
    deal[:start_date]
  end

  def end_date
    deal[:end_date]
  end

  def created_date
    deal[:created_at]
  end

  def closed_date
    deal[:closed_at]
  end

  def close_reason
    deal[:closed_reason]
  end

  def close_comments
    deal[:closed_reason_text]
  end

  def members
    deal[:members].map do |member|
      "#{member[:name]} #{member[:share]}%"
    end.join('; ')
  end

  def team
    deal[:team]
  end

  def type
    deal[:type]
  end

  def source
    deal[:source]
  end

  def initiative
    deal[:initiative]
  end

  def method_missing(name)
    deal_custom_field = deal_custom_fields.find_by('lower(field_label) = ?', name.to_s.gsub('_', ' '))

    deal[:custom_fields][deal_custom_field.id.to_s] if deal_custom_field
  end

  def billing_contact
    (deal[:billing_contact]['name'] + '/' + deal[:billing_contact]['email']) rescue nil
  end

  private

  attr_reader :deal, :company

  def deal_custom_fields
    @_deal_custom_fields ||= company.deal_custom_field_names
  end
end
