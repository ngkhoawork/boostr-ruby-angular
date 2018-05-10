class Importers::ContractSpecialTermsService < Importers::BaseService
  attr_accessor :costs

  def perform
    import
  end

  private

  def build_csv(row)
    Csv::ContractSpecialTerm.new(
      contract_id: row[:contract_id],
      contract_name: row[:contract_name],
      term_name: row[:term_name],
      term_type: row[:term_type],
      comments: row[:comments],
      company_id: company_id
    )
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'SpecialTerm'
  end

  def import_source
    'ui'
  end
end