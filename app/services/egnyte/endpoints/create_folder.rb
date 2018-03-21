class Egnyte::Endpoints::CreateFolder < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain folder_path access_token)
    end

    def predefined_request_params
      { action: 'add_folder' }
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

  def path
    "pubapi/v1/fs/#{@options[:folder_path]}"
  end

  def request_params
    {
      action: predefined_request_params[:action]
    }
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end
end
