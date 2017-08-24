class Report::BaseAuditLogSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper

  attributes :id, :name, :advertiser_name, :start_date, :budget, :date, :old_value, :new_value

  private

  def id
    object.auditable_id
  end

  def name
    deal.name
  end

  def advertiser_name
    deal.advertiser.name
  end

  def start_date
    deal.start_date
  end

  def budget
    number_to_currency(deal.budget, precision: 0)
  end

  def date
    object.created_at rescue nil
  end

  def deal
    @_deal ||= Deal.with_deleted.find(object.auditable_id)
  end
end
