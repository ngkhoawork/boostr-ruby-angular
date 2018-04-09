class Dataexport::DealProductBudgetSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::BudgetFields
  include Dataexport::CommonFields::TimestampFields

  attributes :deal_product_id, :start_date, :end_date, :budget_usd, :budget, :created, :last_updated
end
