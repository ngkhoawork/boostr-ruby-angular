class Report::PipelineSummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @seller_id           = params[:seller_id]
    @stage_ids           = params[:stage_ids]
    @type_id             = params[:type_id]
    @source_id           = params[:source_id]
    @start_date          = params[:start_date]
    @end_date            = params[:end_date]
    @created_date_start  = params[:created_date_start]
    @created_date_end    = params[:created_date_end]
    @closed_date_start   = params[:closed_date_start]
    @closed_date_end     = params[:closed_date_end]
  end

  def perform
    ActiveModel::ArraySerializer.new(
      data_for_serializer,
      each_serializer: Report::PipelineSummarySerializer,
      deal_custom_fields: deal_custom_fields
    )
  end

  private

  attr_reader :company, :team_id, :seller_id, :type_id, :source_id, :start_date, :end_date, :created_date_start,
              :created_date_end, :stage_ids, :closed_date_start, :closed_date_end

  def deals
    @_deals ||=
      company.deals
        .by_team_id(team_id)
        .by_seller_id(seller_id)
        .by_stage_ids(stage_ids)
        .by_start_date(start_date, end_date)
        .by_created_date(created_date_start, created_date_end)
        .closed_at(closed_date_start, closed_date_end)
        .includes(
          stage: {},
          deal_custom_field: {},
          initiative: {},
          currency: {},
          deal_contacts: {
            address: {}
          },
          deal_members: {
            user: {
              team: {}
            }
          },
          values: {
            option: {}
          },
          agency: {
            holding_company: {}
          },
          advertiser: {
            client_category: {}
          }
        ).distinct
  end

  def data_for_serializer
    @_data_for_serializer ||=
      if source_id.present? && type_id.present?
        deals.with_all_options([type_id, source_id])
      elsif source_id.present? || type_id.present?
        deals.by_options([type_id, source_id])
      else
        deals
      end
  end

  def deal_custom_fields
    company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end
