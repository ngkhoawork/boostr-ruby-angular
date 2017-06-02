class CreateEalertStages < ActiveRecord::Migration
  def change
    create_table :ealert_stages do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :ealert, index: true, foreign_key: true
      t.belongs_to :stage, index: true, foreign_key: true
      t.string :recipients
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
