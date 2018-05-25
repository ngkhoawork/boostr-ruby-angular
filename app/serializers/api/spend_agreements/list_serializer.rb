class Api::SpendAgreements::ListSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :status,
             :spend_agreement_type,
             :start_date,
             :end_date,
             :target,
             :manually_tracked,
             :company_id,
             :advertisers,
             :agencies,
             :created_at,
             :updated_at

  has_one :holding_company, serializer: Api::Clients::SingleSerializer
  has_many :publishers, serializer: Api::Clients::SingleSerializer
  has_many :parent_companies, serializer: Api::Clients::SingleSerializer
  has_many :values, serializer: Api::Values::SingleSerializer

  def advertisers
    object.clients.select{ |client| client.client_type_id == @options[:advertiser_type_id] }.collect{|el| {id: el.id, name: el.name} }
  end

  def agencies
    object.clients.select{ |client| client.client_type_id == @options[:agency_type_id] }.collect{|el| {id: el.id, name: el.name} }
  end

  def spend_agreement_type
    object.value_from_field(@options[:type_field_id])
  end

  def status
    object.value_from_field(@options[:status_field_id])
  end
end
