class AddInitiativeIdColumnToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :initiative_id, :integer
  end
end
