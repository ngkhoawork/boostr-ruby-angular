class UpdatePmpMembers < ActiveRecord::Migration
  def up
    change_column :pmp_members, :from_date, :date
    change_column :pmp_members, :to_date, :date
  end

  def down
    change_column :pmp_members, :from_date, :datetime
    change_column :pmp_members, :to_date, :datetime
  end
end
