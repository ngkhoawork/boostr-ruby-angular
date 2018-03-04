class Egnyte::Endpoints::MoveFolder < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain folder_id destination access_token)
    end

    def predefined_request_params
      { action: 'move' }
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  private

  delegate :required_option_keys, :predefined_request_params, to: :class

  def request_method
    :post
  end

  def domain
    @options[:domain].sub(/https?:\/\//, '')
  end

  def path
    "pubapi/v1/fs/ids/folder/#{@options[:folder_id]}"
  end

  def request_params
    {
      destination: @options[:destination],
      action: predefined_request_params[:action],
    }
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end
end
