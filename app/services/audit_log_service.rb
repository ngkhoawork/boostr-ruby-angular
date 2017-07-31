class AuditLogService
  STAGE_CHANGE_TYPE = 'Stage Change'.freeze

  def initialize(attrs)
    @record = attrs[:record]
    @type = attrs[:type]
    @member_user_id = attrs[:member]
    @old_value = attrs[:old_value]
    @new_value = attrs[:new_value]
  end

  def perform
    record.audit_logs.create(
      type_of_change: type,
      old_value: old_value,
      new_value: new_value,
      updated_by: User.current.id,
      user_id: member_user_id,
      company: record.company,
      biz_days: calculate_biz_days
    )
  end

  private

  attr_reader :record, :type, :member_user_id, :old_value, :new_value

  def calculate_biz_days
    return nil unless type.eql? STAGE_CHANGE_TYPE

    if logs_by_type.present?
      (Date.current - logs_by_type.order(created_at: :desc).first.created_at.to_date).to_i
    else
      (Date.current - record.created_at.to_date).to_i
    end
  end

  def logs_by_type
    @_logs_by_type ||= record.audit_logs.where(type_of_change: type)
  end
end
