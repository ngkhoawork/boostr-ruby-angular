require 'net/sftp'

class Operative::GetFileService
  FOLDER = 'datafeed'

  def initialize(auth_details)
    @company_name = auth_details.fetch(:company_name).try(:upcase)
    @host = auth_details.fetch(:host)
    @login = auth_details.fetch(:login)
    @password = auth_details.fetch(:password)
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
    "./#{FOLDER}/#{company_name}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  def data_filename_local
    "./#{Dir.tmpdir}/#{FOLDER}/#{company_name}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
