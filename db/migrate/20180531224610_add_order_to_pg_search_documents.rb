class AddOrderToPgSearchDocuments < ActiveRecord::Migration
  def change
    add_column :pg_search_documents, :order, :integer
  end
end
