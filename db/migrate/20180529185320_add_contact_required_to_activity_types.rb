class AddContactRequiredToActivityTypes < ActiveRecord::Migration
  def change
    add_column :activity_types, :contact_required, :boolean, default: false
  end
end
