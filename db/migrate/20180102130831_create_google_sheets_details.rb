class CreateGoogleSheetsDetails < ActiveRecord::Migration
  def change
    create_table :google_sheets_details do |t|
      t.string :sheet_id
      t.references :api_configuration, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
