class CreateSsps < ActiveRecord::Migration
  def change
    create_table :ssps do |t|
    	t.string :name
    end
  end
end
