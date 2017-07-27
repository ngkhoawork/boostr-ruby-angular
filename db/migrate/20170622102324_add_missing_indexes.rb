class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :activities, :activity_type_id
    add_index :activities, :agency_id
    add_index :activities, :client_id
    add_index :activities, :company_id
    add_index :activities, :created_by
    add_index :activities, :deal_id
    add_index :activities, :updated_by
    add_index :activities, :user_id
    add_index :addresses, [:addressable_id, :addressable_type]
    add_index :assets, :created_by
    add_index :assets, [:attachable_id, :attachable_type]
    add_index :client_connections, :advertiser_id
    add_index :client_connections, :agency_id
    add_index :client_connections, [:advertiser_id, :advertiser_id]
    add_index :client_connections, [:agency_id, :agency_id]
    add_index :clients, :company_id
    add_index :clients, :parent_client_id
    add_index :companies, :billing_contact_id
    add_index :companies, :primary_contact_id
    add_index :contacts, :client_id
    add_index :contacts, :company_id
    add_index :content_fees, :product_id
    add_index :deal_members, :deal_id
    add_index :deal_members, :user_id
    add_index :deal_product_budgets, :deal_product_id
    add_index :deal_product_cfs, :deal_product_id
    add_index :deal_products, :deal_id
    add_index :deal_products, :product_id
    add_index :deal_stage_logs, :company_id
    add_index :deal_stage_logs, :deal_id
    add_index :deal_stage_logs, :previous_stage_id
    add_index :deal_stage_logs, :stage_id
    add_index :deal_stage_logs, :stage_updated_by
    add_index :deals, :advertiser_id
    add_index :deals, :agency_id
    add_index :deals, :company_id
    add_index :deals, :created_by
    add_index :deals, :initiative_id
    add_index :deals, :previous_stage_id
    add_index :deals, :stage_id
    add_index :deals, :stage_updated_by
    add_index :deals, :updated_by
    add_index :display_line_items, :temp_io_id
    add_index :ealert_custom_fields, [:subject_id, :subject_type]
    add_index :initiatives, :company_id
    add_index :integration_logs, :deal_id
    add_index :integrations, [:integratable_id, :integratable_type]
    add_index :ios, :company_id
    add_index :ios, :deal_id
    add_index :notifications, :company_id
    add_index :products, :company_id
    add_index :quota, :company_id
    add_index :quota, :time_period_id
    add_index :quota, :user_id
    add_index :reminders, :user_id
    add_index :reminders, [:remindable_id, :remindable_type]
    add_index :revenues, :client_id
    add_index :revenues, :company_id
    add_index :revenues, :product_id
    add_index :revenues, :user_id
    add_index :snapshots, :company_id
    add_index :snapshots, :time_period_id
    add_index :snapshots, :user_id
    add_index :stages, :company_id
    add_index :teams, :company_id
    add_index :temp_ios, :io_id
    add_index :time_periods, :company_id
    add_index :users, :company_id
    add_index :users, [:invited_by_id, :invited_by_type]
  end
end