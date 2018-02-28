class AddDealIdToPmp < ActiveRecord::Migration
  def change
    add_reference :pmps, :deal, foreign_key: true
  end
end
