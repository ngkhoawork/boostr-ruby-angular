class AuditLogService
  def initialize(attrs)
    @record         = attrs[:record]
    @type           = attrs[:type]
    @member_user_id = attrs[:member]
    @old_value      = attrs[:old_value]
    @new_value      = attrs[:new_value]
    @changed_amount = attrs[:changed_amount]
    @user           = User.current
  end

  def perform
    record.audit_logs.create(
      type_of_change: type,
      old_value: old_value,
      new_value: new_value,
      updated_by: determine_updated_by,
      user_id: member_user_id,
      company: record.company,
      biz_days: calculate_biz_days,
      changed_amount: changed_amount
    )
  end

  private

  attr_reader :record, :type, :member_user_id, :old_value, :new_value, :changed_amount, :user

  def calculate_biz_days
    return nil unless type.eql? AuditLog::STAGE_CHANGE_TYPE

    if logs_by_type.present?
      (Date.current - logs_by_type.order(created_at: :desc).first.created_at.to_date).to_i
    else
      (Date.current - record.created_at.to_date).to_i
    end
  end

  def logs_by_type
    @_logs_by_type ||= record.audit_logs.where(type_of_change: type)
  end

  def determine_updated_by
    user.id rescue record.updated_by
  end
end
