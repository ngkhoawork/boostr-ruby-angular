class Users::CompanyInfoSerializer < Users::BaseSerializer
  attributes :is_active,
             :is_admin,
             :is_legal,
             :default_currency,
             :roles,
             :company_influencer_enabled,
             :company_egnyte_enabled,
             :company_forecast_gap_to_quota_positive,
             :company_net_forecast_enabled,
             :has_forecast_permission,
             :has_multiple_sales_process,
             :product_options_enabled,
             :product_option1,
             :product_option2,
             :product_option1_enabled,
             :product_option2_enabled,
             :egnyte_authenticated,
             :leads_enabled,
             :revenue_requests_access,
             :contracts_enabled,
             :user_type,
             :title,
             :win_rate,
             :starting_page

  has_one :team, serializer: TeamSerializer
  has_many :teams, serializer: TeamSerializer
end
