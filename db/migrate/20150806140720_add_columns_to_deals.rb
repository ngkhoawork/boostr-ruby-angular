class AddColumnsToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :deal_type, :string
    add_column :deals, :source_type, :string
    add_column :deals, :next_steps, :string
    add_column :deals, :created_by, :integer
  end
end
