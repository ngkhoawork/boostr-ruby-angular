class Search::DealSerializer < ActiveModel::Serializer
  attributes(
      :id,
      :name,
      :budget_loc,
      :budget,
      :start_date,
      :end_date,
      :advertiser,
      :agency,
      :stage
  )

  has_one :currency

  private

  def advertiser
    object.advertiser.serializable_hash(only: [:id, :name]) rescue nil
  end

  def agency
    object.agency.serializable_hash(only: [:id, :name]) rescue nil
  end

  def stage
    object.stage.serializable_hash(only: [:name, :probability]) rescue nil
  end

  def budget
    object.budget.to_f
  end

  def budget_loc
    object.budget_loc.to_f
  end
end
