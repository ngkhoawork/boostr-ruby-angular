class UpdateSettings < ActiveRecord::Migration
  def up
    remove_index :settings, %i(thing_type thing_id var)
    remove_column :settings, :thing_id
    remove_column :settings, :thing_type
  end

  def down
    add_column :settings, :thing_id, :integer, null: true
    add_column :settings, :thing_type, :string, null: true, limit: 30
    add_index :settings, %i(thing_type thing_id var), unique: true
  end
end
