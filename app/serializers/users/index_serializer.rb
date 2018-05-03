class Users::CompanyInfoSerializer < Users::BaseSerializer
  attributes :is_admin, :leader?,
    :agreements_enabled,
    :company_egnyte_enabled,
    :company_forecast_gap_to_quota_positive,
    :company_influencer_enabled,
    :company_net_forecast_enabled,
    :contracts_enabled,
    :default_currency,
    :has_forecast_permission,
    :has_multiple_sales_process,
    :leads_enabled,
    :product_option1,
    :product_option2,
    :product_option1_enabled,
    :product_option2_enabled,
    :product_options_enabled,
    :revenue_requests_access
end
