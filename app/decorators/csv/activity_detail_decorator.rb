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
    activity.comment unless activity.activity_type_name.eql?('Email')
  end

  def advertiser
    activity.client.name rescue EMPTY_LINE
  end

  def agency
    activity.agency.name rescue EMPTY_LINE
  end

  def contacts
    activity.contacts.pluck(:name).join("\n")
  end

  def deal
    activity.deal.name rescue EMPTY_LINE
  end

  def creator
    activity.creator.name rescue EMPTY_LINE
  end

  def team
    activity.team_creator rescue EMPTY_LINE
  end

  def publisher
    activity.publisher.name rescue EMPTY_LINE
  end

  private

  attr_reader :activity
end
