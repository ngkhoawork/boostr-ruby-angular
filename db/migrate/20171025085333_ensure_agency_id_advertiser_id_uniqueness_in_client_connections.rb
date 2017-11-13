class EnsureAgencyIdAdvertiserIdUniquenessInClientConnections < ActiveRecord::Migration
  def change
    uniq_record_ids = ClientConnection.group(:agency_id, :advertiser_id).minimum(:id).values
    ClientConnection.where.not(id: uniq_record_ids).delete_all
  end
end
