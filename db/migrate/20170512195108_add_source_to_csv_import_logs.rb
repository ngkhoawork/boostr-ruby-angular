class AddSourceToCsvImportLogs < ActiveRecord::Migration
  def change
    add_column :csv_import_logs, :source, :string
  end
end
