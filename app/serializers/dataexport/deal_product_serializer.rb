class Dataexport::DealProductSerializer < ActiveModel::Serializer
  attributes :id, :product_id, :budget_usd, :budget, :created, :last_updated, :open, :custom_fields

  def budget_usd
    object.budget
  end

  def budget
    object.budget_loc
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end

  def custom_fields
    object.deal.company.deal_product_cf_names.reduce({}) do |result, field|
      result.merge(field.field_label.downcase.gsub(' ', '_') => object&.deal_product_cf&.public_send(field.field_name))
    end
  end
end
