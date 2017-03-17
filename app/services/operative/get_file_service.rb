require 'net/sftp'

class Operative::GetFileService
  FOLDER = 'datafeed'

  def initialize(auth_details)
    @company_name = auth_details.company.name
    @host = auth_details.base_link
    @login = auth_details.api_email
    @password = auth_details.password
  end

  def perform
    get_files
  end

  private
  attr_reader :company_name, :host, :login, :password

  def get_files
    Net::SFTP.start(host, login, password: password) do |sftp|
      # download a file or directory from the remote host
      sftp.download!(data_filename_remote, data_filename_local)
    end
    data_filename_local
  end

  def data_filename_remote
    "./#{FOLDER}/#{company_name.upcase}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  def data_filename_local
    ".#{Dir.tmpdir}/#{company_name.upcase}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
