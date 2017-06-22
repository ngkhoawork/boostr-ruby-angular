class AddDealsIndexes < ActiveRecord::Migration
  def change
    def change
      add_index :deals, :id
      add_index :deals, :agency_id
      add_index :deals, :advertiser_id
      add_index :deals, :stage_id
      add_index :deals, :name
    end
  end
end
