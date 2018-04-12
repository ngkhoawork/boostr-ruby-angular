class ChangeWebLeadToCreatedFromForDealsContactsClients < ActiveRecord::Migration
  def change
    rename_column :clients, :web_lead, :created_from
    change_column :clients, :created_from, :string

    rename_column :contacts, :web_lead, :created_from
    change_column :contacts, :created_from, :string

    rename_column :deals, :web_lead, :created_from
    change_column :deals, :created_from, :string
  end
end
