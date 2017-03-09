require 'net/sftp'

class Operative::GetFileService
  FOLDER = 'datafeed'

  def initialize(auth_details)
    @company_name = auth_details.fetch(:company_name).upcase
    @host = auth_details.fetch(:host)
    @login = auth_details.fetch(:login)
    @password = auth_details.fetch(:password)
  end

  def perform
    create_directory
    get_files
  end

  private
  attr_reader :company_name, :host, :login, :password

  def create_directory
    Dir.mkdir(FOLDER) unless File.exists?(FOLDER)
  end

  def get_files
    Net::SFTP.start(host, login, password: password) do |sftp|
      # download a file or directory from the remote host
      sftp.download!(control_filename, control_filename)
      sftp.download!(data_filename, data_filename)

      # sftp.file.open("/datafeed/KING_CONTROLFILE_03012017_v3.csv", "r") do |f|
      #   binding.pry
      # end

      # list the entries in a directory
      # sftp.dir.foreach("/datafeed") do |entry|
      #   puts entry.longname
      # end
    end
    [control_filename, data_filename]
  end

  def control_filename
    "./#{FOLDER}/#{company_name}_CONTROLFILE_#{timestamp}_v3.csv"
  end

  def data_filename
    "./#{FOLDER}/#{company_name}_DataFeed_#{timestamp}_v3.tar.gz"
  end

  def timestamp
    Date.today.strftime('%m%d%Y')
  end
end
