class UpdateEnableOperativeExtraFieldsForMashableCompany < ActiveRecord::Migration
  def change
    Company.find(29).update(enable_operative_extra_fields: true) if Company.find(29).present?
  end
end
