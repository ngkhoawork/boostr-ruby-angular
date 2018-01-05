class AddMemberRoleIdToPublisherMember < ActiveRecord::Migration
  def change
    add_column :publisher_members, :role_id, :integer
    add_index :publisher_members, :role_id
  end
end
