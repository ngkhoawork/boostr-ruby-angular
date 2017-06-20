class UpdateEnableOperativeExtraFieldsForMashableCompany < ActiveRecord::Migration
  def change
    Company.where(id: 29).update_all(enable_operative_extra_fields: true)
  end
end
