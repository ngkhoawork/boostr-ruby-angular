class CsvReportGenerator
  def initialize(data, header = [])
    @data = data
    @header = header
  end

  def generate
    CSV.generate do |csv|
      csv << header
      csv << rows
    end
  end

  def rows
    data_lines = []
    data.each do |data_item|
      data_lines << data_item
    end
    data_lines
  end

  private

  attr_reader :data, :header

end