class Report::StageChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :start_date, :stage_name, :budget, :previous_stage, :date

  private

  def advertiser_name
    object.auditable.advertiser.name
  end

  def start_date
    object.auditable.start_date
  end

  def stage_name
    Stage.find(object.new_value).name
  end

  def budget
    object.auditable.budget
  end

  def previous_stage
    Stage.find(object.old_value).name rescue nil
  end

  def id
    object.auditable_id
  end

  def name
    object.auditable.name
  end

  def date
    object.created_at
  end
end
