class Report::ShareChangedSerializer < Report::BaseAuditLogSerializer
  private

  def old_value
    "#{object.old_value}%"
  end

  def new_value
    "#{object.new_value}%"
  end
end
