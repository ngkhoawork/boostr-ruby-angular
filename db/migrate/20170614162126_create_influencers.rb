class CreateInfluencers < ActiveRecord::Migration
  def change
    create_table :influencers do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :name
      t.boolean :active
      t.string :address
      t.string :email
      t.string :phone

      t.timestamps null: false
    end
  end
end
