class CreatePublisherStages < ActiveRecord::Migration
  def change
    create_table :publisher_stages do |t|
      t.integer :company_id, index: true

      t.timestamps null: false
    end
  end
end
