class AddLinkFieldToDealCustomFields < ActiveRecord::Migration
  def change
    add_column :deal_custom_fields, :link1, :string
  end
end
