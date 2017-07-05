class AddDoctypeToImportLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :doctype, :string, default: ''
  end
end
