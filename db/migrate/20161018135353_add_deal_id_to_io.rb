class AddDealIdToIo < ActiveRecord::Migration
  def change
    add_reference :ios, :deal, foreign_key: true
  end
end
