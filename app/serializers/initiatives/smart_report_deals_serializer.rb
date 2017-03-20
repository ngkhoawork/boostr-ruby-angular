class Initiatives::SmartReportDealsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :agency_name, :budget, :stage, :probability, :start_date, :next_steps,
             :last_activity
  attribute :closed_reason, if: :deal_lost?

  def advertiser_name
    object.advertiser.name
  end

  def agency_name
    object.agency.name if object.agency.present?
  end

  def budget
    object.budget.to_i
  end

  def stage
    object.stage.name
  end

  def probability
    object.stage.probability
  end

  def start_date
    object.start_date.strftime('%-m/%-d/%Y')
  end

  def last_activity
    activities.first.activity_type_name if activities.any?
  end

  def activities
    @_activities ||= object.activities.order('happened_at desc')
  end

  def closed_reason
    Deal.get_option(object, 'Close Reason')
  end

  def deal_lost?
    object.closed_lost?
  end
end
