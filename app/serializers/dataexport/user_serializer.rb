class Dataexport::UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :office, :employee_id, :currency, :active, :created, :last_updated

  def currency
    object.default_currency
  end

  def active
    object.is_active
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
