require 'rubygems/package'
require 'zlib'

class Operative::ExtractVerifyService
  FOLDER = './tmp/'

  def initialize(archive, timestamp, intraday: false, hhmm: '')
    @archive = archive
    @timestamp = timestamp
    @intraday = intraday
    @hhmm = hhmm
  end

  def perform
    extract_from_archive
  end

  private

  attr_reader :archive, :timestamp, :intraday, :hhmm

  def extract_from_archive
    extracted_files = {}
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(archive))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      if entry.file? && datafeed_payload.include?(entry.full_name)
        dest = File.join FOLDER, destination_file_name(entry.full_name)
        extracted_files[to_table_name(entry.full_name)] = dest
        File.open dest, "wb" do |f|
          f.print entry.read
        end
      end
    end

    tar_extract.close
    extracted_files
  end

  def datafeed_payload
    [
      "Sales_Order_#{timestamp}.csv",
      "Invoice_Line_Item_#{timestamp}.csv",
      "Invoice_#{timestamp}.csv",
      "Sales_Order_Line_Items_#{timestamp}.csv",
      "Currency_#{timestamp}.csv"
    ]
  end

  def to_table_name(name)
    name.split("_#{timestamp}").first.downcase.to_sym
  end

  def destination_file_name(file_name)
    intraday ? file_name.gsub(/\.csv/, "#{hhmm}_intraday.csv") { |match|  } : file_name
  end
end
