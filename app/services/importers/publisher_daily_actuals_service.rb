class Importers::PublisherDailyActualsService < Importers::BaseService

  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    Csv::PublisherDailyActual.new(
      date: row[:date],
      available_impressions: row[:available_impressions],
      filled_impressions: row[:filled_impressions],
      company_id: row[:company_id],
      publisher_id: row[:publisher_id],
      publisher_name: row[:publisher_name]
    )
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end
end
