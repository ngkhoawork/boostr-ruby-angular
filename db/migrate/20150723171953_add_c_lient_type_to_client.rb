class AddCLientTypeToClient < ActiveRecord::Migration
  def change
    add_column :clients, :client_type, :string
  end
end
