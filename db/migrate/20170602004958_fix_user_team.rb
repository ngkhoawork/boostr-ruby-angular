class FixUserTeam < ActiveRecord::Migration
  def change
    User.all.each do |user|
      if user.leader? && user.team_id.present?
        user.team_id = nil
        puts "======="
        puts user.id
        user.save
      end
    end
  end
end
