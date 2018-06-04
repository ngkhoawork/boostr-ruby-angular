class Search::IoSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :io_number,
      :name,
      :budget_loc,
      :budget,
      :start_date,
      :end_date,
      :advertiser,
      :agency
  )

  has_one :currency

  private

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def budget
    object.budget.to_f
  end

  def budget_loc
    object.budget_loc.to_f
  end
end
