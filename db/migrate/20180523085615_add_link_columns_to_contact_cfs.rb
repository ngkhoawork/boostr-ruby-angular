class AddLinkColumnsToContactCfs < ActiveRecord::Migration
  def change
    add_column :contact_cfs, :link1, :string
    add_column :contact_cfs, :link2, :string
    add_column :contact_cfs, :link3, :string
    add_column :contact_cfs, :link4, :string
    add_column :contact_cfs, :link5, :string
    add_column :contact_cfs, :link6, :string
    add_column :contact_cfs, :link7, :string
    add_column :contact_cfs, :link8, :string
    add_column :contact_cfs, :link9, :string
    add_column :contact_cfs, :link10, :string
  end
end
