class Report::StageChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :start_date, :old_value, :budget, :new_value, :date

  private

  def advertiser_name
    deal.advertiser.name
  end

  def start_date
    deal.start_date
  end

  def new_value
    Stage.find(object.new_value).name rescue nil
  end

  def budget
    deal.budget
  end

  def old_value
    Stage.find(object.old_value).name rescue nil
  end

  def id
    object.auditable_id
  end

  def name
    deal.name
  end

  def date
    object.created_at
  end

  def deal
    @_deal ||= Deal.with_deleted.find(object.auditable_id)
  end
end
