class Dataexport::IoSerializer < ActiveModel::Serializer
  attributes :id, :io_number, :advertiser_id, :agency_id, :budget_usd, :budget, :start_date, :end_date,
             :external_io_number, :created, :last_updated, :name, :deal_id, :currency

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

  def currency
    object.curr_cd
  end
end
