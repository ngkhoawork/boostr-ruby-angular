class Report::PipelineSummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @member_id           = params[:member_id]
    @stage_ids           = params[:stage_ids]
    @type_id             = params[:type_id]
    @source_id           = params[:source_id]
    @start_date          = params[:start_date]
    @end_date            = params[:end_date]
    @created_date_start  = params[:created_date_start]
    @created_date_end    = params[:created_date_end]
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: Report::PipelineSummarySerializer,
      deal_custom_fields: deal_custom_fields
    )
  end

  private

  attr_reader :company, :team_id, :member_id, :type_id, :source_id, :start_date, :end_date, :created_date_start,
              :created_date_end, :stage_ids

  def data_for_serializer
    company.deals
           .includes(
             :stage,
             :deal_custom_field,
             :initiative,
             :currency,
             deal_members: [{ user: :team }],
             values: [:option],
             agency: [:holding_company],
             advertiser: [:client_category]
           )
           .by_team_id(team_id)
           .by_seller_id(member_id)
           .by_stage_ids(stage_ids)
           .by_start_date(start_date, end_date)
           .by_created_date(created_date_start, created_date_end)
           .by_options([type_id, source_id])
  end

  def deal_custom_fields
    company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end
