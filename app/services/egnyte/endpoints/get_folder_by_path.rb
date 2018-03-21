class Egnyte::Endpoints::GetFolderByPath < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain folder_path access_token)
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  private

  delegate :required_option_keys, to: :class

  def request_method
    :get
  end


  def path
    "pubapi/v1/fs/#{@options[:folder_path]}"
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end
end
