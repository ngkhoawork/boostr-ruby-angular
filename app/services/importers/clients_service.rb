class Importers::ClientsService < Importers::BaseService
  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    params = Csv::Client::ATTRS.each_with_object({}) {|attr, obj| obj[attr] = row[attr]}
    params[:unmatched_fields] = row.except(*params.keys)
    params[:company_fields] = company_fields
    params[:company_id] = company_id
    params[:user_id] = user_id

    Csv::Client.new(params)
  end

  def parser_options
    { strip_chars_from_headers: /[\-"]/ }
  end

  def company_fields
    @_company_fields ||= Models::AccountCompanyDataService.new(company_id).perform
  end

  def import_source
    'ui'
  end
end
