class AddNoteToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :note, :text
  end
end
