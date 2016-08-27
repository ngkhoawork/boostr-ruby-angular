class RemoveLeaderIdFromDeletedTeams < ActiveRecord::Migration
  def change
    Team.deleted.update_all(leader_id: nil)
  end
end
