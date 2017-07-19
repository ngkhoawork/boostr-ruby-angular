# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170717161630) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_cf_names", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "field_index"
    t.string   "field_type"
    t.string   "field_label"
    t.boolean  "is_required"
    t.integer  "position"
    t.boolean  "show_on_modal"
    t.boolean  "disabled"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "account_cf_names", ["company_id"], name: "index_account_cf_names_on_company_id", using: :btree

  create_table "account_cf_options", force: :cascade do |t|
    t.integer  "account_cf_name_id"
    t.string   "value"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "account_cf_options", ["account_cf_name_id"], name: "index_account_cf_options_on_account_cf_name_id", using: :btree

  create_table "account_cfs", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "client_id"
    t.decimal  "currency1",      precision: 15, scale: 2
    t.decimal  "currency2",      precision: 15, scale: 2
    t.decimal  "currency3",      precision: 15, scale: 2
    t.decimal  "currency4",      precision: 15, scale: 2
    t.decimal  "currency5",      precision: 15, scale: 2
    t.decimal  "currency6",      precision: 15, scale: 2
    t.decimal  "currency7",      precision: 15, scale: 2
    t.string   "currency_code1"
    t.string   "currency_code2"
    t.string   "currency_code3"
    t.string   "currency_code4"
    t.string   "currency_code5"
    t.string   "currency_code6"
    t.string   "currency_code7"
    t.string   "text1"
    t.string   "text2"
    t.string   "text3"
    t.string   "text4"
    t.string   "text5"
    t.text     "note1"
    t.text     "note2"
    t.datetime "datetime1"
    t.datetime "datetime2"
    t.datetime "datetime3"
    t.datetime "datetime4"
    t.datetime "datetime5"
    t.datetime "datetime6"
    t.datetime "datetime7"
    t.decimal  "number1",        precision: 15, scale: 2
    t.decimal  "number2",        precision: 15, scale: 2
    t.decimal  "number3",        precision: 15, scale: 2
    t.decimal  "number4",        precision: 15, scale: 2
    t.decimal  "number5",        precision: 15, scale: 2
    t.decimal  "number6",        precision: 15, scale: 2
    t.decimal  "number7",        precision: 15, scale: 2
    t.decimal  "integer1",       precision: 15
    t.decimal  "integer2",       precision: 15
    t.decimal  "integer3",       precision: 15
    t.decimal  "integer4",       precision: 15
    t.decimal  "integer5",       precision: 15
    t.decimal  "integer6",       precision: 15
    t.decimal  "integer7",       precision: 15
    t.boolean  "boolean1"
    t.boolean  "boolean2"
    t.boolean  "boolean3"
    t.decimal  "percentage1",    precision: 5,  scale: 2
    t.decimal  "percentage2",    precision: 5,  scale: 2
    t.decimal  "percentage3",    precision: 5,  scale: 2
    t.decimal  "percentage4",    precision: 5,  scale: 2
    t.decimal  "percentage5",    precision: 5,  scale: 2
    t.string   "dropdown1"
    t.string   "dropdown2"
    t.string   "dropdown3"
    t.string   "dropdown4"
    t.string   "dropdown5"
    t.string   "dropdown6"
    t.string   "dropdown7"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.decimal  "number_4_dec1",  precision: 15, scale: 4
    t.decimal  "number_4_dec2",  precision: 15, scale: 4
    t.decimal  "number_4_dec3",  precision: 15, scale: 4
    t.decimal  "number_4_dec4",  precision: 15, scale: 4
    t.decimal  "number_4_dec5",  precision: 15, scale: 4
    t.decimal  "number_4_dec6",  precision: 15, scale: 4
    t.decimal  "number_4_dec7",  precision: 15, scale: 4
  end

  add_index "account_cfs", ["client_id"], name: "index_account_cfs_on_client_id", using: :btree
  add_index "account_cfs", ["company_id"], name: "index_account_cfs_on_company_id", using: :btree

  create_table "account_dimensions", force: :cascade do |t|
    t.string  "name"
    t.integer "account_type"
    t.integer "category_id"
    t.integer "subcategory_id"
  end

  create_table "account_pipeline_facts", force: :cascade do |t|
    t.integer "company_id"
    t.integer "account_dimension_id"
    t.integer "time_dimension_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.integer "pipeline_amount"
  end

  add_index "account_pipeline_facts", ["account_dimension_id"], name: "index_account_pipeline_facts_on_account_dimension_id", using: :btree
  add_index "account_pipeline_facts", ["company_id"], name: "index_account_pipeline_facts_on_company_id", using: :btree
  add_index "account_pipeline_facts", ["time_dimension_id"], name: "index_account_pipeline_facts_on_time_dimension_id", using: :btree

  create_table "account_revenue_facts", force: :cascade do |t|
    t.integer "company_id"
    t.integer "account_dimension_id"
    t.integer "time_dimension_id"
    t.integer "category_id"
    t.integer "subcategory_id"
    t.decimal "revenue_amount",       precision: 10, scale: 2
  end

  add_index "account_revenue_facts", ["account_dimension_id"], name: "index_account_revenue_facts_on_account_dimension_id", using: :btree
  add_index "account_revenue_facts", ["company_id"], name: "index_account_revenue_facts_on_company_id", using: :btree
  add_index "account_revenue_facts", ["time_dimension_id"], name: "index_account_revenue_facts_on_time_dimension_id", using: :btree

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "deal_id"
    t.integer  "client_id"
    t.string   "activity_type_name"
    t.datetime "happened_at"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.text     "comment"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "timed"
    t.integer  "activity_type_id"
    t.string   "google_event_id"
    t.integer  "agency_id"
    t.string   "uuid"
  end

  create_table "activities_contacts", force: :cascade do |t|
    t.integer "activity_id"
    t.integer "contact_id"
  end

  add_index "activities_contacts", ["activity_id"], name: "index_activities_contacts_on_activity_id", using: :btree
  add_index "activities_contacts", ["contact_id"], name: "index_activities_contacts_on_contact_id", using: :btree

  create_table "activity_types", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "action"
    t.string   "icon"
    t.integer  "updated_by"
    t.integer  "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ad_units", force: :cascade do |t|
    t.text     "name"
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ad_units", ["product_id"], name: "index_ad_units_on_product_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.string   "website"
    t.string   "phone"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "mobile"
    t.string   "country"
  end

  create_table "api_configurations", force: :cascade do |t|
    t.string   "integration_type"
    t.boolean  "switched_on"
    t.integer  "trigger_on_deal_percentage"
    t.integer  "company_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "base_link"
    t.string   "api_email"
    t.string   "encrypted_password"
    t.string   "encrypted_password_iv"
    t.text     "encrypted_json_api_key"
    t.text     "encrypted_json_api_key_iv"
    t.string   "network_code"
    t.string   "integration_provider"
    t.boolean  "recurring",                  default: false
  end

  add_index "api_configurations", ["company_id"], name: "index_api_configurations_on_company_id", using: :btree

  create_table "asana_connect_details", force: :cascade do |t|
    t.string   "project_name"
    t.string   "workspace_name"
    t.integer  "company_id"
    t.integer  "api_configuration_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "asana_connect_details", ["api_configuration_id"], name: "index_asana_connect_details_on_api_configuration_id", using: :btree
  add_index "asana_connect_details", ["company_id"], name: "index_asana_connect_details_on_company_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "asset_file_name"
    t.string   "asset_file_size"
    t.string   "asset_content_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "original_file_name"
    t.string   "comment"
    t.string   "subtype"
    t.integer  "created_by"
    t.integer  "company_id"
  end

  create_table "bp_estimate_products", force: :cascade do |t|
    t.integer  "bp_estimate_id"
    t.integer  "product_id"
    t.float    "estimate_seller"
    t.float    "estimate_mgr"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bp_estimate_products", ["bp_estimate_id"], name: "index_bp_estimate_products_on_bp_estimate_id", using: :btree
  add_index "bp_estimate_products", ["product_id"], name: "index_bp_estimate_products_on_product_id", using: :btree

  create_table "bp_estimates", force: :cascade do |t|
    t.integer  "bp_id"
    t.integer  "client_id"
    t.integer  "user_id"
    t.float    "estimate_seller"
    t.float    "estimate_mgr"
    t.string   "objectives"
    t.string   "assumptions"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "bp_estimates", ["bp_id"], name: "index_bp_estimates_on_bp_id", using: :btree
  add_index "bp_estimates", ["client_id"], name: "index_bp_estimates_on_client_id", using: :btree
  add_index "bp_estimates", ["user_id"], name: "index_bp_estimates_on_user_id", using: :btree

  create_table "bps", force: :cascade do |t|
    t.string   "name"
    t.integer  "time_period_id"
    t.date     "due_date"
    t.integer  "company_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "read_only",      default: false
  end

  add_index "bps", ["company_id"], name: "index_bps_on_company_id", using: :btree
  add_index "bps", ["time_period_id"], name: "index_bps_on_time_period_id", using: :btree

  create_table "client_connections", force: :cascade do |t|
    t.integer  "agency_id"
    t.integer  "advertiser_id"
    t.boolean  "primary",       default: false
    t.boolean  "active",        default: true
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "client_contacts", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "contact_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "primary",    default: false, null: false
    t.boolean  "is_active",  default: true,  null: false
  end

  add_index "client_contacts", ["client_id", "contact_id"], name: "index_client_contacts_on_client_id_and_contact_id", using: :btree

  create_table "client_members", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "user_id"
    t.integer  "share"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "client_members", ["client_id"], name: "index_client_members_on_client_id", using: :btree
  add_index "client_members", ["user_id"], name: "index_client_members_on_user_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "website"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
    t.integer  "advertiser_deals_count", default: 0, null: false
    t.integer  "agency_deals_count",     default: 0, null: false
    t.integer  "contacts_count",         default: 0, null: false
    t.integer  "client_type_id"
    t.datetime "activity_updated_at"
    t.integer  "client_category_id"
    t.integer  "client_subcategory_id"
    t.integer  "parent_client_id"
    t.integer  "client_region_id"
    t.integer  "client_segment_id"
    t.integer  "holding_company_id"
    t.text     "note"
  end

  add_index "clients", ["client_category_id"], name: "index_clients_on_client_category_id", using: :btree
  add_index "clients", ["client_region_id"], name: "index_clients_on_client_region_id", using: :btree
  add_index "clients", ["client_segment_id"], name: "index_clients_on_client_segment_id", using: :btree
  add_index "clients", ["client_subcategory_id"], name: "index_clients_on_client_subcategory_id", using: :btree
  add_index "clients", ["client_type_id"], name: "index_clients_on_client_type_id", using: :btree
  add_index "clients", ["deleted_at"], name: "index_clients_on_deleted_at", using: :btree
  add_index "clients", ["holding_company_id"], name: "index_clients_on_holding_company_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "primary_contact_id"
    t.integer  "billing_contact_id"
    t.datetime "created_at",                                                                                                                           null: false
    t.datetime "updated_at",                                                                                                                           null: false
    t.integer  "quantity"
    t.integer  "cost"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "snapshot_day",                      default: 0
    t.integer  "yellow_threshold"
    t.integer  "red_threshold"
    t.integer  "deals_needed_calculation_duration", default: 90
    t.boolean  "ealert_reminder",                   default: false
    t.jsonb    "forecast_permission",               default: {"0"=>true, "1"=>true, "2"=>true, "3"=>true, "4"=>true, "5"=>true, "6"=>true, "7"=>true}, null: false
    t.boolean  "requests_enabled",                  default: false
    t.boolean  "enable_operative_extra_fields",     default: false
    t.jsonb    "io_permission",                     default: {"0"=>true, "1"=>true, "2"=>true, "3"=>true, "4"=>true, "5"=>true, "6"=>true, "7"=>true}, null: false
  end

  add_index "companies", ["forecast_permission"], name: "index_companies_on_forecast_permission", using: :gin
  add_index "companies", ["io_permission"], name: "index_companies_on_io_permission", using: :gin

  create_table "contact_cf_names", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "field_index"
    t.string   "field_type"
    t.string   "field_label"
    t.boolean  "is_required"
    t.integer  "position"
    t.boolean  "show_on_modal"
    t.boolean  "disabled"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "contact_cf_names", ["company_id"], name: "index_contact_cf_names_on_company_id", using: :btree

  create_table "contact_cf_options", force: :cascade do |t|
    t.integer  "contact_cf_name_id"
    t.string   "value"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "contact_cf_options", ["contact_cf_name_id"], name: "index_contact_cf_options_on_contact_cf_name_id", using: :btree

  create_table "contact_cfs", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "contact_id"
    t.decimal  "currency1",      precision: 15, scale: 2
    t.decimal  "currency2",      precision: 15, scale: 2
    t.decimal  "currency3",      precision: 15, scale: 2
    t.decimal  "currency4",      precision: 15, scale: 2
    t.decimal  "currency5",      precision: 15, scale: 2
    t.decimal  "currency6",      precision: 15, scale: 2
    t.decimal  "currency7",      precision: 15, scale: 2
    t.string   "currency_code1"
    t.string   "currency_code2"
    t.string   "currency_code3"
    t.string   "currency_code4"
    t.string   "currency_code5"
    t.string   "currency_code6"
    t.string   "currency_code7"
    t.string   "text1"
    t.string   "text2"
    t.string   "text3"
    t.string   "text4"
    t.string   "text5"
    t.text     "note1"
    t.text     "note2"
    t.datetime "datetime1"
    t.datetime "datetime2"
    t.datetime "datetime3"
    t.datetime "datetime4"
    t.datetime "datetime5"
    t.datetime "datetime6"
    t.datetime "datetime7"
    t.decimal  "number1",        precision: 15, scale: 2
    t.decimal  "number2",        precision: 15, scale: 2
    t.decimal  "number3",        precision: 15, scale: 2
    t.decimal  "number4",        precision: 15, scale: 2
    t.decimal  "number5",        precision: 15, scale: 2
    t.decimal  "number6",        precision: 15, scale: 2
    t.decimal  "number7",        precision: 15, scale: 2
    t.decimal  "integer1",       precision: 15
    t.decimal  "integer2",       precision: 15
    t.decimal  "integer3",       precision: 15
    t.decimal  "integer4",       precision: 15
    t.decimal  "integer5",       precision: 15
    t.decimal  "integer6",       precision: 15
    t.decimal  "integer7",       precision: 15
    t.boolean  "boolean1"
    t.boolean  "boolean2"
    t.boolean  "boolean3"
    t.decimal  "percentage1",    precision: 5,  scale: 2
    t.decimal  "percentage2",    precision: 5,  scale: 2
    t.decimal  "percentage3",    precision: 5,  scale: 2
    t.decimal  "percentage4",    precision: 5,  scale: 2
    t.decimal  "percentage5",    precision: 5,  scale: 2
    t.string   "dropdown1"
    t.string   "dropdown2"
    t.string   "dropdown3"
    t.string   "dropdown4"
    t.string   "dropdown5"
    t.string   "dropdown6"
    t.string   "dropdown7"
    t.decimal  "number_4_dec1",  precision: 15, scale: 4
    t.decimal  "number_4_dec2",  precision: 15, scale: 4
    t.decimal  "number_4_dec3",  precision: 15, scale: 4
    t.decimal  "number_4_dec4",  precision: 15, scale: 4
    t.decimal  "number_4_dec5",  precision: 15, scale: 4
    t.decimal  "number_4_dec6",  precision: 15, scale: 4
    t.decimal  "number_4_dec7",  precision: 15, scale: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "contact_cfs", ["company_id"], name: "index_contact_cfs_on_company_id", using: :btree
  add_index "contact_cfs", ["contact_id"], name: "index_contact_cfs_on_contact_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "client_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "company_id"
    t.datetime "deleted_at"
    t.datetime "activity_updated_at"
    t.text     "note"
  end

  add_index "contacts", ["deleted_at"], name: "index_contacts_on_deleted_at", using: :btree

  create_table "content_fee_product_budgets", force: :cascade do |t|
    t.integer  "content_fee_id"
    t.decimal  "budget",          precision: 15, scale: 2
    t.date     "start_date"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.date     "end_date"
    t.decimal  "budget_loc",      precision: 15, scale: 2, default: 0.0
    t.string   "billing_status",                           default: "Pending"
    t.boolean  "manual_override",                          default: false
  end

  add_index "content_fee_product_budgets", ["content_fee_id"], name: "index_content_fee_product_budgets_on_content_fee_id", using: :btree

  create_table "content_fees", force: :cascade do |t|
    t.integer  "io_id"
    t.integer  "product_id"
    t.decimal  "budget",     precision: 15, scale: 2
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.decimal  "budget_loc", precision: 15, scale: 2, default: 0.0
  end

  add_index "content_fees", ["io_id"], name: "index_content_fees_on_io_id", using: :btree

  create_table "cpm_budget_adjustments", force: :cascade do |t|
    t.float    "percentage"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "api_configuration_id"
  end

  add_index "cpm_budget_adjustments", ["api_configuration_id"], name: "index_cpm_budget_adjustments_on_api_configuration_id", using: :btree

  create_table "csv_import_logs", force: :cascade do |t|
    t.integer  "rows_processed", default: 0
    t.integer  "rows_imported",  default: 0
    t.integer  "rows_failed",    default: 0
    t.integer  "rows_skipped",   default: 0
    t.text     "error_messages"
    t.string   "file_source"
    t.string   "object_name"
    t.integer  "company_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "source"
  end

  add_index "csv_import_logs", ["company_id"], name: "index_csv_import_logs_on_company_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string "curr_cd"
    t.string "curr_symbol"
    t.string "name"
  end

  create_table "deal_contacts", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "role"
  end

  add_index "deal_contacts", ["deal_id", "contact_id"], name: "index_deal_contacts_on_deal_id_and_contact_id", using: :btree

  create_table "deal_custom_field_names", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "field_index"
    t.string   "field_type"
    t.string   "field_label"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "is_required"
    t.integer  "position"
    t.boolean  "show_on_modal"
    t.boolean  "disabled"
  end

  add_index "deal_custom_field_names", ["company_id"], name: "index_deal_custom_field_names_on_company_id", using: :btree

  create_table "deal_custom_field_options", force: :cascade do |t|
    t.integer  "deal_custom_field_name_id"
    t.string   "value"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "deal_custom_field_options", ["deal_custom_field_name_id"], name: "index_deal_custom_field_options_on_deal_custom_field_name_id", using: :btree

  create_table "deal_custom_fields", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "deal_id"
    t.decimal  "currency1",      precision: 15, scale: 2
    t.decimal  "currency2",      precision: 15, scale: 2
    t.decimal  "currency3",      precision: 15, scale: 2
    t.decimal  "currency4",      precision: 15, scale: 2
    t.decimal  "currency5",      precision: 15, scale: 2
    t.decimal  "currency6",      precision: 15, scale: 2
    t.decimal  "currency7",      precision: 15, scale: 2
    t.string   "currency_code1"
    t.string   "currency_code2"
    t.string   "currency_code3"
    t.string   "currency_code4"
    t.string   "currency_code5"
    t.string   "currency_code6"
    t.string   "currency_code7"
    t.string   "text1"
    t.string   "text2"
    t.string   "text3"
    t.string   "text4"
    t.string   "text5"
    t.text     "note1"
    t.text     "note2"
    t.datetime "datetime1"
    t.datetime "datetime2"
    t.datetime "datetime3"
    t.datetime "datetime4"
    t.datetime "datetime5"
    t.datetime "datetime6"
    t.datetime "datetime7"
    t.decimal  "number1",        precision: 15, scale: 2
    t.decimal  "number2",        precision: 15, scale: 2
    t.decimal  "number3",        precision: 15, scale: 2
    t.decimal  "number4",        precision: 15, scale: 2
    t.decimal  "number5",        precision: 15, scale: 2
    t.decimal  "number6",        precision: 15, scale: 2
    t.decimal  "number7",        precision: 15, scale: 2
    t.decimal  "integer1",       precision: 15
    t.decimal  "integer2",       precision: 15
    t.decimal  "integer3",       precision: 15
    t.decimal  "integer4",       precision: 15
    t.decimal  "integer5",       precision: 15
    t.decimal  "integer6",       precision: 15
    t.decimal  "integer7",       precision: 15
    t.boolean  "boolean1"
    t.boolean  "boolean2"
    t.boolean  "boolean3"
    t.decimal  "percentage1",    precision: 5,  scale: 2
    t.decimal  "percentage2",    precision: 5,  scale: 2
    t.decimal  "percentage3",    precision: 5,  scale: 2
    t.decimal  "percentage4",    precision: 5,  scale: 2
    t.decimal  "percentage5",    precision: 5,  scale: 2
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "dropdown1"
    t.string   "dropdown2"
    t.string   "dropdown3"
    t.string   "dropdown4"
    t.string   "dropdown5"
    t.string   "dropdown6"
    t.string   "dropdown7"
    t.integer  "sum1"
    t.integer  "sum2"
    t.integer  "sum3"
    t.integer  "sum4"
    t.integer  "sum5"
    t.integer  "sum6"
    t.integer  "sum7"
    t.decimal  "number_4_dec1",  precision: 15, scale: 4
    t.decimal  "number_4_dec2",  precision: 15, scale: 4
    t.decimal  "number_4_dec3",  precision: 15, scale: 4
    t.decimal  "number_4_dec4",  precision: 15, scale: 4
    t.decimal  "number_4_dec5",  precision: 15, scale: 4
    t.decimal  "number_4_dec6",  precision: 15, scale: 4
    t.decimal  "number_4_dec7",  precision: 15, scale: 4
    t.string   "link1"
  end

  add_index "deal_custom_fields", ["company_id"], name: "index_deal_custom_fields_on_company_id", using: :btree
  add_index "deal_custom_fields", ["deal_id"], name: "index_deal_custom_fields_on_deal_id", using: :btree

  create_table "deal_logs", force: :cascade do |t|
    t.integer  "deal_id"
    t.decimal  "budget_change",     precision: 15, scale: 2
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.decimal  "budget_change_loc", precision: 15, scale: 2, default: 0.0
  end

  add_index "deal_logs", ["deal_id"], name: "index_deal_logs_on_deal_id", using: :btree

  create_table "deal_members", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "user_id"
    t.integer  "share"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deal_product_budgets", force: :cascade do |t|
    t.decimal  "budget",          precision: 15, scale: 2, default: 0.0
    t.date     "period"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "deal_product_id"
    t.decimal  "budget_loc",      precision: 15, scale: 2, default: 0.0
  end

  create_table "deal_product_cf_names", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "field_index"
    t.string   "field_type"
    t.string   "field_label"
    t.boolean  "is_required"
    t.integer  "position"
    t.boolean  "show_on_modal"
    t.boolean  "disabled"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "deal_product_cf_names", ["company_id"], name: "index_deal_product_cf_names_on_company_id", using: :btree

  create_table "deal_product_cf_options", force: :cascade do |t|
    t.integer  "deal_product_cf_name_id"
    t.string   "value"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "deal_product_cf_options", ["deal_product_cf_name_id"], name: "index_deal_product_cf_options_on_deal_product_cf_name_id", using: :btree

  create_table "deal_product_cfs", force: :cascade do |t|
    t.integer  "company_id"
    t.decimal  "currency1",       precision: 15, scale: 2
    t.decimal  "currency2",       precision: 15, scale: 2
    t.decimal  "currency3",       precision: 15, scale: 2
    t.decimal  "currency4",       precision: 15, scale: 2
    t.decimal  "currency5",       precision: 15, scale: 2
    t.decimal  "currency6",       precision: 15, scale: 2
    t.decimal  "currency7",       precision: 15, scale: 2
    t.string   "currency_code1"
    t.string   "currency_code2"
    t.string   "currency_code3"
    t.string   "currency_code4"
    t.string   "currency_code5"
    t.string   "currency_code6"
    t.string   "currency_code7"
    t.string   "text1"
    t.string   "text2"
    t.string   "text3"
    t.string   "text4"
    t.string   "text5"
    t.text     "note1"
    t.text     "note2"
    t.datetime "datetime1"
    t.datetime "datetime2"
    t.datetime "datetime3"
    t.datetime "datetime4"
    t.datetime "datetime5"
    t.datetime "datetime6"
    t.datetime "datetime7"
    t.decimal  "number1",         precision: 15, scale: 2
    t.decimal  "number2",         precision: 15, scale: 2
    t.decimal  "number3",         precision: 15, scale: 2
    t.decimal  "number4",         precision: 15, scale: 2
    t.decimal  "number5",         precision: 15, scale: 2
    t.decimal  "number6",         precision: 15, scale: 2
    t.decimal  "number7",         precision: 15, scale: 2
    t.decimal  "integer1",        precision: 15
    t.decimal  "integer2",        precision: 15
    t.decimal  "integer3",        precision: 15
    t.decimal  "integer4",        precision: 15
    t.decimal  "integer5",        precision: 15
    t.decimal  "integer6",        precision: 15
    t.decimal  "integer7",        precision: 15
    t.boolean  "boolean1"
    t.boolean  "boolean2"
    t.boolean  "boolean3"
    t.decimal  "percentage1",     precision: 5,  scale: 2
    t.decimal  "percentage2",     precision: 5,  scale: 2
    t.decimal  "percentage3",     precision: 5,  scale: 2
    t.decimal  "percentage4",     precision: 5,  scale: 2
    t.decimal  "percentage5",     precision: 5,  scale: 2
    t.string   "dropdown1"
    t.string   "dropdown2"
    t.string   "dropdown3"
    t.string   "dropdown4"
    t.string   "dropdown5"
    t.string   "dropdown6"
    t.string   "dropdown7"
    t.integer  "sum1"
    t.integer  "sum2"
    t.integer  "sum3"
    t.integer  "sum4"
    t.integer  "sum5"
    t.integer  "sum6"
    t.integer  "sum7"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "deal_product_id"
    t.decimal  "number_4_dec1",   precision: 15, scale: 4
    t.decimal  "number_4_dec2",   precision: 15, scale: 4
    t.decimal  "number_4_dec3",   precision: 15, scale: 4
    t.decimal  "number_4_dec4",   precision: 15, scale: 4
    t.decimal  "number_4_dec5",   precision: 15, scale: 4
    t.decimal  "number_4_dec6",   precision: 15, scale: 4
    t.decimal  "number_4_dec7",   precision: 15, scale: 4
  end

  add_index "deal_product_cfs", ["company_id"], name: "index_deal_product_cfs_on_company_id", using: :btree

  create_table "deal_products", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "product_id"
    t.decimal  "budget",     precision: 15, scale: 2, default: 0.0
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "open",                                default: true
    t.decimal  "budget_loc", precision: 15, scale: 2, default: 0.0
  end

  create_table "deal_stage_logs", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "deal_id"
    t.integer  "stage_id"
    t.integer  "stage_updated_by"
    t.datetime "stage_updated_at"
    t.string   "operation"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "active_wday"
    t.integer  "previous_stage_id"
  end

  create_table "deals", force: :cascade do |t|
    t.integer  "advertiser_id"
    t.integer  "agency_id"
    t.integer  "company_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.decimal  "budget",              precision: 15, scale: 2, default: 0.0
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "stage_id"
    t.string   "deal_type"
    t.string   "source_type"
    t.string   "next_steps"
    t.integer  "created_by"
    t.datetime "deleted_at"
    t.datetime "closed_at"
    t.integer  "stage_updated_by"
    t.datetime "stage_updated_at"
    t.integer  "updated_by"
    t.datetime "activity_updated_at"
    t.integer  "previous_stage_id"
    t.boolean  "open",                                         default: true
    t.string   "curr_cd",                                      default: "USD"
    t.decimal  "budget_loc",          precision: 15, scale: 2, default: 0.0
    t.integer  "initiative_id"
    t.string   "closed_reason_text"
  end

  add_index "deals", ["deleted_at"], name: "index_deals_on_deleted_at", using: :btree

  create_table "dfp_report_queries", force: :cascade do |t|
    t.integer  "report_type"
    t.string   "weekly_recurrence_day"
    t.integer  "monthly_recurrence_day"
    t.string   "report_id"
    t.boolean  "is_daily_recurrent",     default: false
    t.integer  "api_configuration_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "dfp_report_queries", ["api_configuration_id"], name: "index_dfp_report_queries_on_api_configuration_id", using: :btree

  create_table "display_line_item_budgets", force: :cascade do |t|
    t.integer  "display_line_item_id"
    t.integer  "external_io_number"
    t.float    "budget"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.decimal  "budget_loc",            precision: 15, scale: 2, default: 0.0
    t.string   "billing_status",                                 default: "Pending"
    t.boolean  "manual_override",                                default: false
    t.decimal  "ad_server_budget",      precision: 15, scale: 2
    t.integer  "ad_server_quantity"
    t.integer  "quantity"
    t.integer  "clicks"
    t.decimal  "ctr",                   precision: 5,  scale: 4
    t.decimal  "video_avg_view_rate",   precision: 5,  scale: 4
    t.decimal  "video_completion_rate", precision: 5,  scale: 4
  end

  add_index "display_line_item_budgets", ["display_line_item_id"], name: "index_display_line_item_budgets_on_display_line_item_id", using: :btree

  create_table "display_line_items", force: :cascade do |t|
    t.integer  "io_id"
    t.integer  "line_number"
    t.string   "ad_server"
    t.integer  "quantity"
    t.decimal  "budget",                               precision: 15, scale: 2
    t.string   "pricing_type"
    t.integer  "product_id"
    t.decimal  "budget_delivered",                     precision: 15, scale: 2
    t.decimal  "budget_remaining",                     precision: 15, scale: 2
    t.integer  "quantity_delivered"
    t.integer  "quantity_remaining"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "daily_run_rate"
    t.integer  "num_days_til_out_of_budget", limit: 8
    t.integer  "quantity_delivered_3p"
    t.integer  "quantity_remaining_3p"
    t.decimal  "budget_delivered_3p",                  precision: 15, scale: 2
    t.decimal  "budget_remaining_3p",                  precision: 15, scale: 2
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.decimal  "price",                                precision: 15, scale: 2
    t.integer  "balance",                    limit: 8
    t.datetime "last_alert_at"
    t.integer  "temp_io_id"
    t.string   "ad_server_product"
    t.decimal  "budget_loc",                           precision: 15, scale: 2, default: 0.0
    t.decimal  "budget_delivered_loc",                 precision: 15, scale: 2, default: 0.0
    t.decimal  "budget_remaining_loc",                 precision: 15, scale: 2, default: 0.0
    t.decimal  "budget_delivered_3p_loc",              precision: 15, scale: 2, default: 0.0
    t.decimal  "budget_remaining_3p_loc",              precision: 15, scale: 2, default: 0.0
    t.integer  "balance_loc",                limit: 8
    t.integer  "daily_run_rate_loc"
    t.decimal  "ctr",                                  precision: 5,  scale: 4
    t.integer  "clicks"
    t.text     "ad_unit"
  end

  add_index "display_line_items", ["io_id"], name: "index_display_line_items_on_io_id", using: :btree
  add_index "display_line_items", ["product_id"], name: "index_display_line_items_on_product_id", using: :btree

  create_table "ealert_custom_fields", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "ealert_id"
    t.string   "subject_type"
    t.integer  "subject_id"
    t.integer  "position",     limit: 2, default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "ealert_custom_fields", ["company_id"], name: "index_ealert_custom_fields_on_company_id", using: :btree
  add_index "ealert_custom_fields", ["ealert_id"], name: "index_ealert_custom_fields_on_ealert_id", using: :btree

  create_table "ealert_stages", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "ealert_id"
    t.integer  "stage_id"
    t.string   "recipients"
    t.boolean  "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ealert_stages", ["company_id"], name: "index_ealert_stages_on_company_id", using: :btree
  add_index "ealert_stages", ["ealert_id"], name: "index_ealert_stages_on_ealert_id", using: :btree
  add_index "ealert_stages", ["stage_id"], name: "index_ealert_stages_on_stage_id", using: :btree

  create_table "ealerts", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "recipients"
    t.boolean  "automatic_send"
    t.boolean  "same_all_stages"
    t.integer  "agency",          limit: 2, default: 0
    t.integer  "deal_type",       limit: 2, default: 0
    t.integer  "source_type",     limit: 2, default: 0
    t.integer  "next_steps",      limit: 2, default: 0
    t.integer  "closed_reason",   limit: 2, default: 0
    t.integer  "intiative",       limit: 2, default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "ealerts", ["company_id"], name: "index_ealerts_on_company_id", using: :btree

  create_table "exchange_rates", force: :cascade do |t|
    t.integer "company_id"
    t.date    "start_date"
    t.date    "end_date"
    t.integer "currency_id"
    t.decimal "rate",        precision: 15, scale: 4
  end

  add_index "exchange_rates", ["company_id"], name: "index_exchange_rates_on_company_id", using: :btree
  add_index "exchange_rates", ["currency_id"], name: "index_exchange_rates_on_currency_id", using: :btree

  create_table "fields", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "subject_type"
    t.string   "value_type"
    t.string   "value_object_type"
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "locked"
  end

  add_index "fields", ["company_id"], name: "index_fields_on_company_id", using: :btree
  add_index "fields", ["deleted_at"], name: "index_fields_on_deleted_at", using: :btree
  add_index "fields", ["subject_type"], name: "index_fields_on_subject_type", using: :btree

  create_table "holding_companies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "initiatives", force: :cascade do |t|
    t.string   "name"
    t.integer  "goal"
    t.string   "status"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "integration_logs", force: :cascade do |t|
    t.text     "request_body"
    t.string   "response_code"
    t.text     "response_body"
    t.string   "api_endpoint"
    t.string   "request_type"
    t.string   "resource_type"
    t.integer  "company_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "deal_id"
    t.boolean  "is_error"
    t.string   "api_provider"
    t.string   "object_name"
    t.text     "error_text"
    t.string   "dfp_query_type"
    t.string   "doctype",        default: ""
  end

  add_index "integration_logs", ["company_id"], name: "index_integration_logs_on_company_id", using: :btree

  create_table "integrations", force: :cascade do |t|
    t.integer  "integratable_id"
    t.string   "integratable_type"
    t.integer  "external_id"
    t.string   "external_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "io_members", force: :cascade do |t|
    t.integer  "io_id"
    t.integer  "user_id"
    t.integer  "share"
    t.date     "from_date"
    t.date     "to_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "io_members", ["io_id"], name: "index_io_members_on_io_id", using: :btree
  add_index "io_members", ["user_id"], name: "index_io_members_on_user_id", using: :btree

  create_table "ios", force: :cascade do |t|
    t.integer  "advertiser_id"
    t.integer  "agency_id"
    t.decimal  "budget",             precision: 15, scale: 2
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "external_io_number"
    t.integer  "io_number"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "name"
    t.integer  "company_id"
    t.integer  "deal_id"
    t.decimal  "budget_loc",         precision: 15, scale: 2, default: 0.0
    t.string   "curr_cd",                                     default: "USD"
  end

  add_index "ios", ["advertiser_id"], name: "index_ios_on_advertiser_id", using: :btree
  add_index "ios", ["agency_id"], name: "index_ios_on_agency_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.string   "subject"
    t.text     "message"
    t.boolean  "active"
    t.text     "recipients"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "options", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "field_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "deleted_at"
    t.boolean  "locked",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "option_id"
  end

  add_index "options", ["company_id", "field_id", "position", "deleted_at"], name: "options_index_composite", using: :btree
  add_index "options", ["option_id"], name: "index_options_on_option_id", using: :btree

  create_table "print_items", force: :cascade do |t|
    t.integer  "io_id"
    t.string   "ad_unit"
    t.string   "ad_type"
    t.integer  "rate"
    t.string   "market"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "print_items", ["io_id"], name: "index_print_items_on_io_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "product_line"
    t.string   "family"
    t.string   "revenue_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "active",       default: true
  end

  create_table "quota", force: :cascade do |t|
    t.integer  "time_period_id"
    t.integer  "value"
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "curr_cd"
    t.decimal  "budget_loc",     precision: 15, scale: 2, default: 0.0
  end

  add_index "quota", ["end_date"], name: "index_quota_on_end_date", using: :btree
  add_index "quota", ["start_date"], name: "index_quota_on_start_date", using: :btree

  create_table "reminders", force: :cascade do |t|
    t.string   "name"
    t.text     "comment"
    t.integer  "user_id"
    t.integer  "remindable_id"
    t.string   "remindable_type"
    t.datetime "remind_on"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
    t.boolean  "completed"
  end

  add_index "reminders", ["deleted_at"], name: "index_reminders_on_deleted_at", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "company_id"
    t.integer  "requester_id"
    t.integer  "assignee_id"
    t.integer  "requestable_id"
    t.string   "requestable_type"
    t.string   "status"
    t.string   "request_type"
    t.text     "description",      default: ""
    t.text     "resolution",       default: ""
    t.date     "due_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "requests", ["assignee_id"], name: "index_requests_on_assignee_id", using: :btree
  add_index "requests", ["company_id"], name: "index_requests_on_company_id", using: :btree
  add_index "requests", ["deal_id"], name: "index_requests_on_deal_id", using: :btree
  add_index "requests", ["requester_id"], name: "index_requests_on_requester_id", using: :btree

  create_table "revenues", force: :cascade do |t|
    t.integer  "order_number"
    t.string   "ad_server"
    t.integer  "line_number"
    t.integer  "quantity"
    t.integer  "price"
    t.string   "price_type"
    t.integer  "delivered"
    t.integer  "remaining"
    t.integer  "budget"
    t.integer  "budget_remaining"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "company_id"
    t.integer  "client_id"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "product_id"
    t.integer  "daily_budget"
    t.text     "comment"
    t.integer  "run_rate"
    t.integer  "remaining_day"
    t.integer  "balance"
    t.datetime "last_alert_at"
  end

  create_table "snapshots", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "time_period_id"
    t.integer  "revenue"
    t.integer  "weighted_pipeline"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "year"
    t.integer  "quarter"
  end

  add_index "snapshots", ["end_date"], name: "index_snapshots_on_end_date", using: :btree
  add_index "snapshots", ["start_date"], name: "index_snapshots_on_start_date", using: :btree
  add_index "snapshots", ["year", "quarter"], name: "index_snapshots_on_year_and_quarter", using: :btree

  create_table "stages", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "probability"
    t.boolean  "open"
    t.boolean  "active"
    t.integer  "deals_count"
    t.integer  "position"
    t.string   "color"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "yellow_threshold"
    t.integer  "red_threshold"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "parent_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "leader_id"
    t.integer  "members_count", default: 0, null: false
    t.datetime "deleted_at"
  end

  add_index "teams", ["deleted_at"], name: "index_teams_on_deleted_at", using: :btree
  add_index "teams", ["leader_id"], name: "index_teams_on_leader_id", using: :btree
  add_index "teams", ["parent_id"], name: "index_teams_on_parent_id", using: :btree

  create_table "temp_cumulative_dfp_reports", force: :cascade do |t|
    t.string   "dimensionorder_name"
    t.string   "dimensionadvertiser_name"
    t.string   "dimensionline_item_name"
    t.string   "dimensionad_unit_name"
    t.integer  "dimensionorder_id"
    t.integer  "dimensionadvertiser_id"
    t.integer  "dimensionline_item_id"
    t.integer  "dimensionad_unit_id"
    t.datetime "dimensionattributeorder_start_date_time"
    t.datetime "dimensionattributeorder_end_date_time"
    t.string   "dimensionattributeorder_agency"
    t.datetime "dimensionattributeline_item_start_date_time"
    t.datetime "dimensionattributeline_item_end_date_time"
    t.string   "dimensionattributeline_item_cost_type"
    t.integer  "dimensionattributeline_item_cost_per_unit",          limit: 8
    t.integer  "dimensionattributeline_item_goal_quantity",          limit: 8
    t.integer  "dimensionattributeline_item_non_cpd_booked_revenue", limit: 8
    t.integer  "columntotal_line_item_level_impressions",            limit: 8
    t.integer  "columntotal_line_item_level_clicks",                 limit: 8
    t.integer  "columntotal_line_item_level_all_revenue",            limit: 8
    t.float    "columntotal_line_item_level_ctr"
    t.float    "columnvideo_viewership_average_view_rate"
    t.float    "columnvideo_viewership_completion_rate"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "temp_ios", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "advertiser"
    t.string   "agency"
    t.decimal  "budget",             precision: 15, scale: 2, default: 0.0
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "external_io_number"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "io_id"
    t.decimal  "budget_loc",         precision: 15, scale: 2, default: 0.0
    t.string   "curr_cd",                                     default: "USD"
  end

  add_index "temp_ios", ["company_id"], name: "index_temp_ios_on_company_id", using: :btree

  create_table "time_dimensions", force: :cascade do |t|
    t.string  "name"
    t.date    "start_date"
    t.date    "end_date"
    t.integer "days_length"
  end

  create_table "time_period_weeks", force: :cascade do |t|
    t.integer  "week"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "period_name"
    t.date     "period_start"
    t.date     "period_end"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "time_periods", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
    t.string   "period_type"
    t.boolean  "visible",     default: true
  end

  add_index "time_periods", ["deleted_at"], name: "index_time_periods_on_deleted_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                               default: "",    null: false
    t.string   "encrypted_password",                  default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask",                          default: 1
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",                   default: 0
    t.string   "title"
    t.integer  "team_id"
    t.boolean  "notify",                              default: false
    t.integer  "neg_balance",             limit: 8
    t.integer  "pos_balance"
    t.datetime "last_alert_at"
    t.integer  "neg_balance_cnt",         limit: 8
    t.integer  "pos_balance_cnt",         limit: 8
    t.integer  "neg_balance_lcnt",        limit: 8
    t.integer  "pos_balance_lcnt",        limit: 8
    t.integer  "neg_balance_l",           limit: 8
    t.integer  "pos_balance_l",           limit: 8
    t.integer  "neg_balance_l_cnt",       limit: 8
    t.integer  "pos_balance_l_cnt",       limit: 8
    t.decimal  "win_rate"
    t.decimal  "average_deal_size"
    t.float    "cycle_time"
    t.integer  "user_type",                           default: 0,     null: false
    t.boolean  "is_active",                           default: true
    t.string   "starting_page"
    t.string   "default_currency",                    default: "USD"
    t.boolean  "revenue_requests_access",             default: false
    t.string   "employee_id",             limit: 20
    t.string   "office",                  limit: 100
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["team_id"], name: "index_users_on_team_id", using: :btree

  create_table "validations", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "factor"
    t.string   "value_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "validations", ["company_id"], name: "index_validations_on_company_id", using: :btree

  create_table "values", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "subject_type"
    t.integer  "subject_id"
    t.integer  "field_id"
    t.string   "value_type"
    t.text     "value_text"
    t.integer  "value_number"
    t.float    "value_float"
    t.datetime "value_datetime"
    t.integer  "value_object_id"
    t.string   "value_object_type"
    t.integer  "option_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.boolean  "value_boolean"
  end

  add_index "values", ["company_id", "field_id"], name: "index_values_on_company_id_and_field_id", using: :btree
  add_index "values", ["option_id"], name: "index_values_on_option_id", using: :btree
  add_index "values", ["subject_type", "subject_id"], name: "index_values_on_subject_type_and_subject_id", using: :btree
  add_index "values", ["value_object_type", "value_object_id"], name: "index_values_on_value_object_type_and_value_object_id", using: :btree

  add_foreign_key "account_cf_names", "companies"
  add_foreign_key "account_cf_options", "account_cf_names"
  add_foreign_key "account_cfs", "clients"
  add_foreign_key "account_cfs", "companies"
  add_foreign_key "account_pipeline_facts", "account_dimensions"
  add_foreign_key "account_pipeline_facts", "companies"
  add_foreign_key "account_pipeline_facts", "time_dimensions"
  add_foreign_key "account_revenue_facts", "account_dimensions"
  add_foreign_key "account_revenue_facts", "companies"
  add_foreign_key "account_revenue_facts", "time_dimensions"
  add_foreign_key "ad_units", "products"
  add_foreign_key "api_configurations", "companies"
  add_foreign_key "asana_connect_details", "api_configurations"
  add_foreign_key "asana_connect_details", "companies"
  add_foreign_key "assets", "companies"
  add_foreign_key "bp_estimate_products", "bp_estimates"
  add_foreign_key "bp_estimate_products", "products"
  add_foreign_key "bp_estimates", "bps"
  add_foreign_key "bp_estimates", "clients"
  add_foreign_key "bp_estimates", "users"
  add_foreign_key "bps", "companies"
  add_foreign_key "bps", "time_periods"
  add_foreign_key "clients", "clients", column: "parent_client_id"
  add_foreign_key "contact_cf_names", "companies"
  add_foreign_key "contact_cf_options", "contact_cf_names"
  add_foreign_key "contact_cfs", "companies"
  add_foreign_key "contact_cfs", "contacts"
  add_foreign_key "content_fee_product_budgets", "content_fees"
  add_foreign_key "content_fees", "ios"
  add_foreign_key "cpm_budget_adjustments", "api_configurations"
  add_foreign_key "csv_import_logs", "companies"
  add_foreign_key "deal_custom_field_names", "companies"
  add_foreign_key "deal_custom_field_options", "deal_custom_field_names"
  add_foreign_key "deal_custom_fields", "companies"
  add_foreign_key "deal_custom_fields", "deals"
  add_foreign_key "deal_logs", "deals"
  add_foreign_key "deal_product_budgets", "deal_products"
  add_foreign_key "deal_product_cf_names", "companies"
  add_foreign_key "deal_product_cf_options", "deal_product_cf_names"
  add_foreign_key "deal_product_cfs", "companies"
  add_foreign_key "dfp_report_queries", "api_configurations"
  add_foreign_key "display_line_item_budgets", "display_line_items"
  add_foreign_key "display_line_items", "ios"
  add_foreign_key "display_line_items", "products"
  add_foreign_key "display_line_items", "temp_ios"
  add_foreign_key "ealert_custom_fields", "companies"
  add_foreign_key "ealert_custom_fields", "ealerts"
  add_foreign_key "ealert_stages", "companies"
  add_foreign_key "ealert_stages", "ealerts"
  add_foreign_key "ealert_stages", "stages"
  add_foreign_key "ealerts", "companies"
  add_foreign_key "exchange_rates", "companies"
  add_foreign_key "exchange_rates", "currencies"
  add_foreign_key "integration_logs", "companies"
  add_foreign_key "io_members", "ios"
  add_foreign_key "io_members", "users"
  add_foreign_key "ios", "companies"
  add_foreign_key "ios", "deals"
  add_foreign_key "print_items", "ios"
  add_foreign_key "requests", "companies"
  add_foreign_key "requests", "deals"
  add_foreign_key "requests", "users", column: "assignee_id"
  add_foreign_key "requests", "users", column: "requester_id"
  add_foreign_key "temp_ios", "companies"
  add_foreign_key "temp_ios", "ios"
  add_foreign_key "users", "teams"
end
