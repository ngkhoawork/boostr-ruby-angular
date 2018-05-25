class Api::SpendAgreements::UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :first_name,
    :last_name,
    :email,
    :office,
    :employee_id
  )
end
