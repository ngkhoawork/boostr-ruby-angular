class GenerateStageDimension < ActiveRecord::Migration
  def change
  	StageDimension.destroy_all
  	Stage.all.each do |stage|
  		stage_dimension_param = {
  			id: stage.id,
  			name: stage.name,
  			company_id: stage.company.present? ? stage.company_id : nil,
  			probability: stage.probability,
  			open: stage.open
  		}
  		stage_dimension = StageDimension.new(stage_dimension_param)
  		stage_dimension.save
  	end
  end
end
