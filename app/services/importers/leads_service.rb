class Importers::LeadsService < Importers::BaseService
  def perform
    import
  end

  private

  def build_csv(row)
    Csv::Lead.new(
      company_id: company_id,
      first_name: row[:first_name],
      last_name: row[:last_name],
      title: row[:title],
      email: row[:sender_email],
      company_name: row[:company_name],
      country: row[:country],
      state: row[:state],
      budget: row[:budget],
      notes: row[:notes],
      status: row[:status],
      assigned_to: row[:assigned_to],
      skip_assignment: row[:skip_assignment]
    )
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end

  def import_subject
    'Lead'
  end

  def import_source
    'ui'
  end
end
