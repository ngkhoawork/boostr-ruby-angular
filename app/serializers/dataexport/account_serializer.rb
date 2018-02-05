class Dataexport::AccountSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :category, :sub_category, :parent_account, :region, :segment,
             :holding_company, :created, :last_updated, :custom_fields

  def type
    object.client_type&.name
  end

  def category
    object.client_category&.name
  end

  def sub_category
    object.client_subcategory&.name
  end

  def parent_account
    object.parent_client&.name
  end

  def region
    object.client_region&.name
  end

  def segment
    object.client_segment&.name
  end

  def holding_company
    object.holding_company&.name
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end

  def custom_fields
    object.company.account_cf_names.reduce({}) do |result, field|
      result.merge(field.field_label.downcase.gsub(' ', '_') => object&.account_cf&.public_send(field.field_name))
    end
  end
end
