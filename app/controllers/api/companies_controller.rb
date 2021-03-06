class Api::CompaniesController < ApplicationController
  respond_to :json

  def show
    render json: company.to_json
  end

  def update
    if company.update_attributes(company_params)
      render json: company
    else
      render json: { errors: company.errors.messages }, status: :unprocessable_entity
    end
  end

  protected

  def company_params
    params.require(:company).permit(
      :snapshot_day,
      :avg_day,
      :yellow_threshold,
      :red_threshold,
      :deals_needed_calculation_duration,
      :ealert_reminder,
      :influencer_enabled,
      :publishers_enabled,
      :logi_enabled,
      :agreements_enabled,
      :leads_enabled,
      :contracts_enabled,
      :forecast_gap_to_quota_positive,
      :product_options_enabled,
      :product_option1_field,
      :product_option2_field,
      :product_option1_enabled,
      :product_option2_enabled,
      :enable_net_forecasting,
      :default_io_freeze_budgets,
      :default_deal_freeze_budgets,
      forecast_permission: ["0", "1", "2", "3", "4", "5", "6", "7"],
      io_permission: ["0", "1", "2", "3", "4", "5", "6", "7"],
      egnyte_integration_attributes: [:id, :app_domain, :enabled]
    )
  end

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end
end
