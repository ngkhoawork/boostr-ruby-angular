class Csv::ActivityDetailDecorator
  EMPTY_LINE = ''.freeze

  def self.required_options
    %i(custom_field_names)
  end

  def initialize(activity, opts = {})
    @activity = activity
    @opts = opts.symbolize_keys

    required_options.each { |opt_name| raise "#{opt_name} option must be present" unless @opts[opt_name] }
  end

  delegate :required_options, to: :class

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

  def method_missing(method_name, *args)
    custom_field_name = @opts[:custom_field_names].detect do |custom_field_name|
      custom_field_name.field_label.parameterize('_') == method_name.to_s
    end

    if custom_field_name
      activity.custom_field&.public_send(custom_field_name.field_name)
    else
      super
    end
  end
end
