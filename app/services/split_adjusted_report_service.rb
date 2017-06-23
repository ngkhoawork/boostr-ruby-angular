class SplitAdjustedReportService
  OPEN_STATUS = 'open'.freeze
  FILTER_ALL_ATTR = 'all'.freeze

  def initialize(company, params)
    @company   = company
    @seller_id = params[:seller_id]
    @team_id   = params[:team_id]
    @stage_ids  = params[:stage_ids]
    @status    = params[:status]
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: SplitAdjustedReportSerializer
    )
  end

  private

  attr_reader :company, :seller_id, :team_id, :stage_ids, :status

  def data_for_serializer
    filtered_deal_members
      .by_seller(seller_params)
      .by_team(team_params)
      .by_stage_ids(stage_ids)
      .order(deal_id: :desc)
  end

  def filtered_deal_members
    status.eql?(FILTER_ALL_ATTR) ? without_status : with_status
  end

  def with_status
    DealMember.with_not_zero_share
      .includes(:user, deal: [:advertiser, :agency, :stage])
      .where(deals: { company_id: company.id, open: status_params })
  end

  def without_status
    DealMember.with_not_zero_share
      .includes(:user, deal: [:advertiser, :agency, :stage])
      .where(deals: { company_id: company.id })
  end

  def seller_params
    determine_params_for(seller_id)
  end

  def team_params
    determine_params_for(team_id)
  end

  def status_params
    status.downcase.eql?(OPEN_STATUS) ? true : false
  end

  def determine_params_for(attr)
    attr.eql?(FILTER_ALL_ATTR) ? nil : attr
  end
end
