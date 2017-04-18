class Api::V1::ClientSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :created_by,
    :updated_by,
    :website,
    :advertiser_deals_count,
    :agency_deals_count,
    :contacts_count,
    :client_type_id,
    :activity_updated_at,
    :client_category_id,
    :client_subcategory_id,
    :parent_client_id,
    :parent_client,
    :deals_count,
    :type_name,
    :fields,
    :formatted_name,
    :address,
    :values,
    :activities,
    :agency_activities,
    :client_contacts,
    :deals,
    :client_members,
    :reminder
  )

  def type_name
    if object.client_type_id == Client.advertiser_type_id(object.company)
      'Advertiser'
    elsif object.client_type_id == Client.agency_type_id(object.company)
      'Agency'
    else
      ''
    end
  end

  def parent_client
    if object.parent_client.present?
      object.parent_client.select(:id, :name)
    else
      nil
    end
  end

  def fields
    object.fields.includes(:options)
  end

  def formatted_name
    object.formatted_name
  end

  def client_contacts
    object.contacts.order(:name).includes(:address)
  end

  def deals
    object.company.deals.active.for_client(object.id).includes(:advertiser, :stage, :previous_stage, :deal_custom_field, :users, :currency).distinct
  end

  def reminder
    object.reminders.where(completed: false).first
  end
end
