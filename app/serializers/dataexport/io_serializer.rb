class Dataexport::IoSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::BudgetFields
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :io_number, :advertiser_id, :agency_id, :budget_usd, :budget, :start_date, :end_date,
             :external_io_number, :created, :last_updated, :name, :deal_id, :currency

  def currency
    object.curr_cd
  end
end
