class CreateHoldingCompanies < ActiveRecord::Migration
  def change
    create_table :holding_companies do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
