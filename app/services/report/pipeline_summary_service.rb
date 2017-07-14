class Report::PipelineSummaryService
  def initialize(company, params)
    @company             = company
    @team_id             = params[:team_id]
    @member_id           = params[:member_id]
    @stage_ids           = params[:stage_ids]
    @type                = params[:type]
    @source              = params[:source]
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

  attr_reader :company, :team_id, :member_id, :type, :source, :start_date, :end_date, :created_date_start,
              :created_date_end

  def data_for_serializer
    company.deals
  end

  def deal_custom_fields
    company.fields.where(subject_type: 'Deal').pluck(:id, :name)
  end
end
