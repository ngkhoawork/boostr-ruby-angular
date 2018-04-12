class Importers::ActivePmpItemImportService < Importers::BaseService

  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    opts = {
        name: row[:name],
        deal_id: row[:deal_id],
        ssp: row[:ssp],
        pmp_type: row[:pmp_type],
        product: row[:product],
        product_level1: row[:product_level1],
        product_level2: row[:product_level2],
        start_date: row[:start_date],
        end_date: row[:end_date],
        budget: row[:budget],
        delivered: row[:delivered]
    }
    Csv::ActivePmpItem.new(opts)
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'ActivePmpItem'
  end

  def import_source
    'ui'
  end
end
