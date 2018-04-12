class AddClientToSspAdvertisers < ActiveRecord::Migration
  def change
    add_reference :ssp_advertisers, :client, index: true, foreign_key: true
  end
end