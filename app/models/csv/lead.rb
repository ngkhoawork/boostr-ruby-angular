class Csv::Lead
  include ActiveModel::Validations

  attr_accessor :company, :first_name, :last_name, :title, :email, :company_name, :country, :state, :budget, :notes,
                :status, :user_id, :skip_assignment

  validates :first_name, :last_name, :email, :country, :state, :budget, :status, :skip_assignment, presence: true
  validates :status, inclusion: { in: ::Lead::STATUSES, message: "should be one from #{::Lead::STATUSES.join(', ')}" }

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.import(file, current_user_id, file_path)
    current_user = User.find(current_user_id)
    company = current_user.company

    import_log = CsvImportLog.new(company_id: company.id, object_name: 'Lead', source: 'ui')
    import_log.set_file_source(file_path)

    CSV.parse(file, headers: true, header_converters: :symbol) do |row|
      import_log.count_processed

      begin
        csv_lead = self.build_lead(row, company)

        if csv_lead.valid?
          csv_lead.save
          import_log.count_imported
        else
          import_log.count_failed
          import_log.log_error csv_lead.errors.full_messages
          next
        end
      rescue Exception => e
        import_log.count_failed
        import_log.log_error ['Internal Server Error', row.to_h.compact.to_s, e.class]
        next
      end
    end

    import_log.save
  end

  def self.build_lead(row, company)
    Csv::Lead.new(
      company: company,
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
      user_id: row[:assigned_to],
      skip_assignment: row[:skip_assignment]
    )
  end

  def lead_assignee_id
    company.users.find_by(email: assigned_to).id rescue nil
  end

  def save
    Lead.create lead_attributes
  end

  def persisted?
    false
  end

  def lead_attributes
    {
      company: company,
      first_name: first_name,
      last_name: last_name,
      title: title,
      email: email,
      company_name: company_name,
      country: country,
      state: state,
      budget: budget,
      notes: notes,
      status: status,
      user_id: lead_assignee_id,
      skip_callback: convert_skip_assignment_to_bool
    }
  end

  def convert_skip_assignment_to_bool
    skip_assignment.downcase.eql?('true')
  end
end
