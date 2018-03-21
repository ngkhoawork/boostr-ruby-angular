class Egnyte::PrivateActions::Base
  def self.required_option_keys
    raise NotImplementedError, __method__
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  private

  delegate :required_option_keys, to: :class
end
