require 'net/sftp'

class Operative::GetFileService
  attr_reader :success, :error
  FOLDER = 'datafeed'

  def initialize(auth_details, date, intraday: false)
    @company_name = auth_details.company_name
    @ftp_url = auth_details.base_link
    @login = auth_details.api_email
    @password = auth_details.password
    @date = date
    @success = false
    @intraday = intraday
  end

  def perform
    get_files
  end

  def data_filename_local
    ".#{Dir.tmpdir}/#{company_name.upcase}_DataFeed_#{timestamp}"
  end

  def data_filename_remote
    "./#{FOLDER}/#{company_name.upcase}_DataFeed_#{timestamp}"
  end

  def hhmm
    @hhmm ||= latest_timestamp || ''
  end

  private

  attr_reader :company_name, :ftp_url, :login, :password, :date, :intraday

  def get_files
    @intraday_candidates = []
    Net::SFTP.start(host, login, password: password) do |sftp|
      if intraday
        sftp.dir.foreach("./#{FOLDER}/") do |entry|
          @intraday_candidates << entry.name if entry.name =~ intraday_pattern
        end
        raise "No suitable intraday file for #{date}" if @intraday_candidates.empty?
      end
      sftp.download!(data_filename_remote, data_filename_local)
    end
    @success = true
  rescue Exception => e
    @error = [e.class.to_s, e.message]
  end

  def host
    return unless ftp_url.present?
    uri = URI.parse(ftp_url)
    uri.class == URI::Generic ? uri.to_s : uri&.host
  end

  def intraday_pattern
    /#{date}_\d\d\d\d_v3_intraday.tar.gz/
  end

  def intraday?
    intraday ? '_intraday' : ''
  end

  def timestamp
    "#{date}#{hhmm}_v3#{intraday?}.tar.gz"
  end

  def latest_timestamp
    return if !@intraday_candidates.present?
    @intraday_candidates.sort.last&.match(/(_\d\d\d\d)_/)&.[](1)
  end
end
