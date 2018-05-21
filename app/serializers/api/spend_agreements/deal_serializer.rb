class Api::SpendAgreements::DealSerializer < ActiveModel::Serializer
  attributes(
    :name,
    :budget,
    :stage,
    :probability,
    :start_date,
    :end_date
  )

  def stage
    object.stage.name
  end

  def probability
    object.stage.probability
  end
end
