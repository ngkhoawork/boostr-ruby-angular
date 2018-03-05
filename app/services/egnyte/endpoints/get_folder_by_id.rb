class Egnyte::Endpoints::GetFolderById < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain folder_id access_token)
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

  def domain
    @options[:domain].sub(/https?:\/\//, '')
  end

  def path
    "pubapi/v1/fs/ids/folder/#{@options[:folder_id]}"
  end

  def request_headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@options[:access_token]}"
    }
  end
end
