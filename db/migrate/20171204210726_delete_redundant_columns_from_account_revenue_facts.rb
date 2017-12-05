class DeleteRedundantColumnsFromAccountRevenueFacts < ActiveRecord::Migration
  def up
    remove_column :account_revenue_facts, :team_name, :string
    remove_column :account_revenue_facts, :seller_names, :string
    remove_reference :account_revenue_facts, :client_region, index: true
    remove_reference :account_revenue_facts, :client_segment, index: true
    add_reference :account_dimensions, :client_region, index: true
    add_reference :account_dimensions, :client_segment, index: true

    AccountDimension.includes(:client).find_each do |account_dimension|
      client = account_dimension.client

      next if client.nil? || (client.client_region_id.nil? && client.client_segment_id.nil?)

      account_dimension.update_columns(
        client_region_id: client.client_region_id,
        client_segment_id: client.client_segment_id
      )
    end
  end

  def down
    remove_reference :account_dimensions, :client_region, index: true
    remove_reference :account_dimensions, :client_segment, index: true
    add_column :account_revenue_facts, :team_name, :string
    add_column :account_revenue_facts, :seller_names, :string, array: true, default: []
    add_reference :account_revenue_facts, :client_region, index: true
    add_reference :account_revenue_facts, :client_segment, index: true

    AccountRevenueFact.includes(:client).find_each do |account_revenue_fact|
      client = account_revenue_fact.client

      next if client.nil? || (client.client_region_id.nil? && client.client_segment_id.nil?)

      account_revenue_fact.update_columns(
        client_region_id: client.client_region_id,
        client_segment_id: client.client_segment_id
      )
    end
  end
end
