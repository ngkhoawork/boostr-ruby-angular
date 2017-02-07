class Operative::Clients::Single < API::Single
  include Representable::JSON

  properties :name, :city, :state, :zip, :phone, :country

  property :external_id, as: :externalID, exec_context: :decorator
  property :industry, exec_context: :decorator
  property :type, as: :accountType, exec_context: :decorator
  property :address_line_1, as: :addressLine1, exec_context: :decorator
  property :address_line_2, as: :addressLine2, exec_context: :decorator
  property :parent_account, as: :parentAccount, exec_context: :decorator

  def external_id
    represented.id
  end

  def type
    represented.agency? ? 'Agency' : 'Advertiser'
  end

  def industry
    represented.category_name
  end

  def address_line_1
    represented.street1
  end

  def address_line_2
    represented.street2
  end

  def parent_account
    represented.parent_client_name
  end
end