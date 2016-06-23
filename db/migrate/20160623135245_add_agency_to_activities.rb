class AddAgencyToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :agency_id, :integer
  end
end
