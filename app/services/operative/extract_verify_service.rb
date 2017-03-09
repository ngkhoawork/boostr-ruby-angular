require 'rubygems/package'
require 'zlib'

class Operative::ExtractVerifyService
  FOLDER = './datafeed/'

  def initialize(files)
    @files = files
  end

  def perform
    extract_from_archive
    # verify_files_presence
    # verify_files_hashsum
  end

  private
  attr_reader :files

  def extract_from_archive
    extracted_files = []
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(datafeed))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      if entry.file? && datafeed_payload.include?(entry.full_name)
        dest = File.join FOLDER, entry.full_name
        File.open dest, "wb" do |f|
          f.print entry.read
        end
      end
      extracted_files << dest
    end

    tar_extract.close
  end

  def datafeed
    archive = files.find { |filename| filename.include?('tar.gz') }
    File.join FOLDER, archive
  end

  def datafeed_payload
    [
      "Sales_Order_#{timestamp}.csv",
      "Invoice_Line_Item_#{timestamp}.csv",
      "Sales_Order_Line_Items_#{timestamp}.csv"
    ]
  end

  def timestamp
    # Date.today.strftime('%m%d%Y')
    '03052017'
  end
end
