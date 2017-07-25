class AuditLogService
  def initialize(record, field)
    @record = record
    @field = field
  end

  def perform
    binding.pry
    record.audit_logs.create(
      changed_field: field,
      old_value: record.start_date_was,
      new_value: record.start_date,
      user: User.current,
      company: record.company
    )
  end

  private

  attr_reader :record, :field
end
