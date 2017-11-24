class Importers::ClientsService < Importers::BaseService
  def perform
    open_file
    import
  end

  private

  def build_csv(row)
    ClientCsv.new(
      email: row[:email],
      name: row[:name],
      title: row[:title],
      team: row[:team],
      currency: row[:currency],
      user_type: row[:user_type],
      status: row[:status],
      is_admin: row[:is_admin],
      revenue_requests: row[:revenue_requests],
      employee_id: row[:employee_id],
      office: row[:office],
      company_id: company_id,
      inviter: inviter
    )
  end

  def parser_options
    { force_simple_split: true, strip_chars_from_headers: /[\-"]/ }
  end
end
