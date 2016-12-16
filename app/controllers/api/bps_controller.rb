class Api::BpsController < ApplicationController
  respond_to :json

  def index
    render json: company.bps.map{ |bp| bp.as_json}
  end

  def create
    bp = company.bps.new(bp_params)
    if bp.save

      render json: bp.as_json, status: :created
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    bp = company.bps.find(params[:id])
    if bp.update_attributes(bp_params)
      render json: bp.as_json
    else
      render json: { errors: bp.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    bp = Bp.find(params[:id])
    # AccountPipelineCalculator.perform_async
    if bp.present?
      time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date, bp.time_period.end_date).to_a
      year_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", bp.time_period.start_date - 1.years, bp.time_period.end_date -  1.years).to_a
      prev_time_dimensions = TimeDimension.where("start_date = ? and end_date = ?", (bp.time_period.start_date - 3.months).beginning_of_month, (bp.time_period.end_date -  3.months).end_of_month).to_a
      pipelines = []
      revenues = []
      year_pipelines = []
      year_revenues = []
      prev_pipelines = []
      prev_revenues = []
      year_time_period = nil
      prev_time_period = nil
      if time_dimensions.count > 0
        pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, time_dimensions[0].id)
        revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, time_dimensions[0].id)
      end
      if year_time_dimensions.count > 0
        year_time_periods = TimePeriod.where(company_id: company.id, start_date: year_time_dimensions[0].start_date, end_date: year_time_dimensions[0].end_date)
        if year_time_periods.count > 0
          year_pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, year_time_dimensions[0].id)
          year_revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, year_time_dimensions[0].id)
          year_time_period = year_time_periods[0]
        end
      end
      if prev_time_dimensions.count > 0
        prev_time_periods = TimePeriod.where(company_id: company.id, start_date: prev_time_dimensions[0].start_date, end_date: prev_time_dimensions[0].end_date)
        if prev_time_periods.count > 0
          prev_pipelines = AccountPipelineFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, prev_time_dimensions[0].id)
          prev_revenues = AccountRevenueFact.where("company_id = ? and time_dimension_id = ?", bp.company.id, prev_time_dimensions[0].id)
          prev_time_period = prev_time_periods[0]
        end
      end

      render json: {
          bp: bp.full_json,
          current: { pipelines: pipelines, revenues: revenues },
          year: { pipelines: year_pipelines, revenues: year_revenues, time_period: year_time_period },
          prev: { pipelines: prev_pipelines, revenues: prev_revenues, time_period: prev_time_period }
      }, status: :ok
    else
      render json: { error: 'Business Plan Not Found' }, status: :not_found
    end
  end

  private

  def bp_params
    params.require(:bp).permit(:name, :time_period_id, :due_date)
  end

  def company
    current_user.company
  end

  def bps
    company.bps
  end
end
