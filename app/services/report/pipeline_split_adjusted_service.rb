class Report::PipelineSplitAdjustedService
  OPEN_STATUS = 'open'.freeze
  FILTER_ALL_ATTR = 'all'.freeze

  def initialize(company, params)
    @company   = company
    @seller_id = params[:seller_id]
    @team_id   = params[:team_id]
    @stage_ids = params[:stage_ids]
    @status    = params[:status].present? ? params[:status] : FILTER_ALL_ATTR
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: Report::SplitAdjustedSerializer, deal_settings_fields: deal_settings_fields
    )
  end

  private

  attr_reader :company, :seller_id, :team_id, :stage_ids, :status

  def data_for_serializer
    filtered_deal_members
      .by_seller(seller_params)
      .by_team(team_params)
      .by_stage_ids(stage_ids)
      .preload(deal: [:advertiser, :agency, :stage, :currency, values: :option])
      .order(deal_id: :desc)
  end

  def filtered_deal_members
    DealMember.with_not_zero_share
      .includes(:user, :deal)
      .where(deals: { company_id: company.id })
      .where('deals.stage_id in (?)', filtered_stages)
  end

  def seller_params
    determine_params_for(seller_id)
  end

  def team_params
    determine_params_for(team_id) if seller_params.nil?
  end

  def status_params
    status.downcase.eql?(FILTER_ALL_ATTR) ? nil : status.downcase.eql?(OPEN_STATUS)
  end

  def filtered_stages
    Stage.for_company(company.id).is_open(status_params).ids
  end

  def determine_params_for(attr)
    attr.eql?(FILTER_ALL_ATTR) ? nil : attr
  end

  def deal_settings_fields
    company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end
