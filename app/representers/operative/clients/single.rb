class Operative::Clients::Single < API::Single

  properties :name, :city, :state, :zip, :phone, :country

  property :external_id, as: :externalID, exec_context: :decorator
  property :industry, exec_context: :decorator
  property :type, as: :accountType, exec_context: :decorator
  property :parent_account, as: :parentAccount, exec_context: :decorator
  property :street1, as: :addressLine1
  property :street2, as: :addressLine2

  def external_id
    "boostr_#{represented.id}##"
  end

  def type
    represented.agency? ? 'agency' : 'advertiser'
  end

  def industry
    represented.category_name
  end

  def parent_account
    represented.parent_client_name
  end
end
