class Importers::ActivePmpObjectImportService < Importers::BaseService

  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    opts = {
        company_id: company_id,
        name: row[:name],
        advertiser: row[:advertiser],
        agency: row[:agency],
        start_date: row[:start_date],
        end_date: row[:end_date],
        team: row[:team],
        is_multibuyer: row[:is_multibuyer]
    }
    Csv::ActivePmpObject.new(opts)
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'ActivePmpObject'
  end

  def import_source
    'ui'
  end
end
