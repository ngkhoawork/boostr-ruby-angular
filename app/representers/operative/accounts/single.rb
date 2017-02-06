class Operative::Accounts::Single < API::Single
  properties :name, :city, :state, :zip, :phone, :country

  property :external_id, exec_context: :decorator
  property :industry, exec_context: :decorator
  property :type, exec_context: :decorator
  property :address_line_1, exec_context: :decorator
  property :address_line_2, exec_context: :decorator
  property :parent_account, exec_context: :decorator

  private

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
    represented.parent_client.try(:name)
  end

end