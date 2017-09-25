class Report::StageChangeDealsAuditLogsSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :advertiser_name, :start_date, :old_value, :new_value, :date, :budget, :biz_days, :changed_by

  private

  def advertiser_name
    advertiser.name rescue nil
  end

  def start_date
    deal.start_date
  end

  def new_value
    Stage.find(object.new_value).name rescue nil
  end

  def budget
    number_to_currency(deal.budget, precision: 0)
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

  def changed_by
    User.find(object.updated_by).name
  end

  def deal
    @_deal ||= Deal.with_deleted.find(object.auditable_id)
  end

  def advertiser
    Client.with_deleted.find(deal.advertiser_id)
  end
end
