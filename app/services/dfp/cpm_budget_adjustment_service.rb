class DFP::CpmBudgetAdjustmentService < BaseService

  def perform(field)
    cpm_budget_adjustment_factor * field.to_i
  end

  def cpm_budget_adjustment_factor_reversed
    (100 + dfp_api_config.cpm_budget_adjustment_percentage) / 100
  end

  private

  def cpm_budget_adjustment_factor
    (100 - dfp_api_config.cpm_budget_adjustment_percentage) / 100
  end

  def dfp_api_config
    @dfp_api_config ||= DfpApiConfiguration.find_by(company_id: company_id)
  end

end
