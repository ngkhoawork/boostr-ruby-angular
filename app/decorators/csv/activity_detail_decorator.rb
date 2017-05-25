class Csv::ActivityDetailDecorator
  EMPTY_LINE = ''.freeze

  def initialize(activity)
    @activity = activity
  end

  def date
    activity.happened_at.strftime('%m/%d/%Y')
  end

  def type
    activity.activity_type_name
  end

  def comments
    activity.comment
  end

  def advertiser
    activity.client.present? ? activity.client.name : EMPTY_LINE
  end

  def agency
    activity.agency.present? ? activity.agency.name : EMPTY_LINE
  end

  def contacts
    activity.contacts.pluck(:name).join("\n")
  end

  def deal
    activity.deal.present? ? activity.deal.name : EMPTY_LINE
  end

  def creator
    activity.creator.present? ? activity.creator.name : EMPTY_LINE
  end

  def team
    activity.team_creator
  end

  private

  attr_reader :activity
end
