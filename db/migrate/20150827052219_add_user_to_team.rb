class AddUserToTeam < ActiveRecord::Migration
  def change
    add_reference :teams, :leader, index: true
    add_column :teams, :members_count, :integer, default: 0, null: false
  end
end
