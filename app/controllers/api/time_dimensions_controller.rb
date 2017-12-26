class Api::TimeDimensionsController < ApplicationController
  def index
    time_dimensions = TimeDimension.all
    render json: time_dimensions
  end

  def revenue_fact_dimension_months
    render json: revenue_fact_dimension_records
  end

  private

  def revenue_fact_dimension_records
    TimeDimension
      .distinct
      .by_existing_revenue_facts(company_id)
      .month_dimensions
  end

  def company_id
    @_company_id ||= current_user.company_id
  end
end
