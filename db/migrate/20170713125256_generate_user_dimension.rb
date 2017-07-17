class GenerateUserDimension < ActiveRecord::Migration
  def change
  	UserDimension.destroy_all
  	User.all.each do |user|
  		team_id = user.team_id
  		if user.leader?
  			team_id = user.teams.first.id
  		end
  		
  		user_dimension_param = {
  			id: user.id,
  			team_id: team_id,
  			company_id: user.company.present? ? user.company_id : nil
  		}
  		user_dimension = UserDimension.new(user_dimension_param)
  		user_dimension.save
  	end
  end
end
