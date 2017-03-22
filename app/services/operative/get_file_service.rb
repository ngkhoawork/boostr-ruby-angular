require 'net/sftp'

class Operative::GetFileService
  attr_reader :success, :error
  FOLDER = 'datafeed'

  def initialize(auth_details, timestamp)
    @company_name = auth_details.company.name
    @host = auth_details.base_link
    @login = auth_details.api_email
    @password = auth_details.password
    @timestamp = timestamp
    @success = false
  end

  def perform
    get_files
  end

  def data_filename_local
    ".#{Dir.tmpdir}/#{company_name.upcase}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  private
  attr_reader :company_name, :host, :login, :password, :timestamp

  def get_files
    begin
      Net::SFTP.start(host, login, password: password) do |sftp|
        sftp.download!(data_filename_remote, data_filename_local)
      end
      @success = true
    rescue Exception => e
      @error = [e.class.to_s, e.message]
    end
  end

  def data_filename_remote
    "./#{FOLDER}/#{company_name.upcase}_DataFeed_#{timestamp}_v3.tar.gz"
  end
end
