class Operative::Contacts::Single < API::Single
  include Representable::JSON

  properties :email, :city, :state, :zip, :phone, :mobile, :country

  property :external_id, as: :externalID, exec_context: :decorator
  property :first_name, as: :firstname, exec_context: :decorator
  property :last_name, as: :lastname, exec_context: :decorator
  property :street1, as: :addressline1
  property :street2, as: :addressline2
  property :type, exec_context: :decorator
  property :account, exec_context: :decorator

  def external_id
    represented.id.to_s
  end

  def first_name
    full_name.first
  end

  def last_name
    full_name.last
  end

  def full_name
    @_full_name ||= represented.name.partition(' ')
  end

  def type
    'Billing'
  end

  def account
    'Testik'
    # Need get here account name
  end
end
