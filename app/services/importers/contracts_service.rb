class Importers::ContractsService < Importers::BaseService
  attr_accessor :costs

  def perform
    import
  end

  private

  def build_csv(row)
    Csv::Contract.new(
      name: row[:name],
      created_date: row[:created_date],
      restricted: row[:restricted],
      type: row[:type],
      status: row[:status],
      auto_renew: row[:auto_renew],
      start_date: row[:start_date],
      end_date: row[:end_date],
      auto_notifications: row[:auto_notifications],
      curr_cd: row[:currency],
      amount: row[:amount]&.to_d,
      description: row[:description],
      days_notice_required: row[:days_notice_required]&.to_i,
      deal_name: row[:deal],
      deal_id: row[:deal_id],
      publisher_name: row[:publisher],
      advertiser_name: row[:advertiser],
      agency_name: row[:agency],
      agency_holding_name: row[:agency_holding],
      company_id: company_id
    )
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'Contract'
  end

  def import_source
    'ui'
  end
end