class Api::SpendAgreements::SingleSerializer < ActiveModel::Serializer
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
             :updated_at,
             :weighted_pipeline_amount,
             :revenue_amount,
             :pipeline_amount,
             :booked_to_target_amount,
             :forecast_to_target_amount,
             :spend_summaries,
             :info_messages

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

  def weighted_pipeline_amount
    calculated_pipeline[:weighted_pipeline].to_f
  end

  def revenue_amount
    calculated_revenue[:revenue_amount].to_f
  end

  def pipeline_amount
    calculated_pipeline[:unweighted_pipeline].to_f
  end

  def spend_summaries
    Calculators::Agreements::SpendSummaryService.new(agreement_id: object.id).perform
  end

  def booked_to_target_amount
    Calculators::Agreements::BookedToTargetService.new(revenue_amount: revenue_amount,
                                                       target_amount: object.target).perform
  end

  def forecast_to_target_amount
    Calculators::Agreements::ForecastToTargetService.new(revenue_amount: revenue_amount,
                                                         weighted_pipeline: weighted_pipeline_amount,
                                                         target_amount: object.target).perform
  end

  def calculated_revenue
    @_calculated_revenue ||= Calculators::Agreements::RevenueService.new(agreement_start_date: object.start_date,
                                                                         agreement_end_date: object.end_date,
                                                                         agreement_id: object.id).perform
  end

  def calculated_pipeline
    @_pipeline_service ||= Calculators::Agreements::PipelineService.new(agreement_start_date: object.start_date,
                                                                        agreement_end_date: object.end_date,
                                                                        agreement_id: object.id).perform
  end
end
