class Dataexport::UserSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :first_name, :last_name, :email, :office, :employee_id, :currency, :active, :created, :last_updated

  def currency
    object.default_currency
  end

  def active
    object.is_active
  end
end
