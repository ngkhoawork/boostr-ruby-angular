class CreatePmpMembers < ActiveRecord::Migration
  def change
    create_table :pmp_members do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :pmp, index: true, foreign_key: true
      t.integer :share
      t.datetime :start_date
      t.datetime :end_date
    end
  end
end
