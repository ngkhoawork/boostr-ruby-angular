class RenameDatesFieldInPmpMembers < ActiveRecord::Migration
  def change
    rename_column :pmp_members, :start_date, :from_date
    rename_column :pmp_members, :end_date, :to_date
  end
end
