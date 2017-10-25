class EnsureAgencyIdAdvertiserIdUniquenessInClientConnections < ActiveRecord::Migration
  def up
    uniq_record_ids = ClientConnection.group(:agency_id, :advertiser_id).minimum(:id).values
    ClientConnection.where.not(id: uniq_record_ids).delete_all
  end

  def down; end
end
