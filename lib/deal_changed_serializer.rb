class DealChangedSerializer < ActiveModel::Serializer
  cached

  attributes(:id, :name, :advertiser_name, :start_date, :stage_name, :budget, :previous_stage)

  private

  def advertiser_name
    object.advertiser_name
  end

  def start_date
    object.start_date
  end

  def stage_name
    object.stage.try(:name)
  end

  def budget
    object.budget
  end

  def previous_stage
    object.previous_stage.try(:name) || ''
  end

  def id
    object.id
  end

  def name
    object.name
  end
end
