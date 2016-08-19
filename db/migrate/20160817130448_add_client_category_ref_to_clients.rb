class AddClientCategoryRefToClients < ActiveRecord::Migration
  def change
    add_reference :clients, :client_category, index: true
    add_reference :clients, :client_subcategory, index: true
  end
end
