require 'net/sftp'

class Operative::GetFileService
  attr_reader :success, :error
  FOLDER = 'datafeed'

  def initialize(auth_details, timestamp)
    @company_name = auth_details.company.name
    @ftp_url = auth_details.base_link
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
  attr_reader :company_name, :ftp_url, :login, :password, :timestamp

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

  def host
    return unless ftp_url.present?
    uri = URI.parse(ftp_url)
    uri.class == URI::Generic ? uri.to_s : uri&.host
  end
end
