class Dataexport::DealProductSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::BudgetFields
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :product_id, :budget_usd, :budget, :created, :last_updated, :open, :custom_fields,
             :deal_id

  def custom_fields
    object.deal.company.deal_product_cf_names.reduce({}) do |result, field|
      result.merge(field.field_label.downcase.gsub(' ', '_') => object&.deal_product_cf&.public_send(field.field_name))
    end
  end
end
