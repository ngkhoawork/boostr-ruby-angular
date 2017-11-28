class Importers::ClientsService < Importers::BaseService
  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    ClientCsv.new(row)
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end
end
