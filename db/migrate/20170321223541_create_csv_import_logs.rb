class CreateCsvImportLogs < ActiveRecord::Migration
  def change
    create_table :csv_import_logs do |t|
      t.integer :rows_processed, default: 0
      t.integer :rows_imported, default: 0
      t.integer :rows_failed, default: 0
      t.integer :rows_skipped, default: 0
      t.text :error_messages
      t.string :file_source
      t.string :object_name
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
