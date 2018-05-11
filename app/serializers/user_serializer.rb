class UserSerializer < Users::BaseSerializer
  attributes :roles_mask,
             :cycle_time,
             :is_active,
             :is_admin,
             :roles,
             :employee_id,
             :leads_enabled,
             :user_type,
             :revenue_requests_access,
             :title,
             :contracts_enabled,
             :is_legal,
             :default_currency,
             :starting_page

  has_one :team, serializer: TeamSerializer
  has_many :teams, serializer: TeamSerializer
end
