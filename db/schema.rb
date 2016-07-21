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

ActiveRecord::Schema.define(version: 20160721065744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

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
  end

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
  end

  add_index "clients", ["client_type_id"], name: "index_clients_on_client_type_id", using: :btree
  add_index "clients", ["deleted_at"], name: "index_clients_on_deleted_at", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "primary_contact_id"
    t.integer  "billing_contact_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "quantity"
    t.integer  "cost"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "snapshot_day",       default: 0
    t.integer  "yellow_threshold"
    t.integer  "red_threshold"
  end

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
  end

  add_index "contacts", ["deleted_at"], name: "index_contacts_on_deleted_at", using: :btree

  create_table "deal_members", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "user_id"
    t.integer  "share"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deal_products", force: :cascade do |t|
    t.integer  "deal_id"
    t.integer  "product_id"
    t.integer  "budget"
    t.date     "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "start_date"
    t.date     "end_date"
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
    t.integer  "budget"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "stage_id"
    t.string   "deal_type"
    t.string   "source_type"
    t.string   "next_steps"
    t.integer  "created_by"
    t.datetime "deleted_at"
    t.date     "closed_at"
    t.integer  "stage_updated_by"
    t.datetime "stage_updated_at"
    t.integer  "updated_by"
    t.datetime "activity_updated_at"
    t.integer  "previous_stage_id"
  end

  add_index "deals", ["deleted_at"], name: "index_deals_on_deleted_at", using: :btree

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
  end

  add_index "options", ["company_id", "field_id", "position", "deleted_at"], name: "options_index_composite", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.string   "product_line"
    t.string   "family"
    t.string   "pricing_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "quota", force: :cascade do |t|
    t.integer  "time_period_id"
    t.integer  "value"
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "quota", ["end_date"], name: "index_quota_on_end_date", using: :btree
  add_index "quota", ["start_date"], name: "index_quota_on_start_date", using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "time_period_id"
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

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

  create_table "time_periods", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "time_periods", ["deleted_at"], name: "index_time_periods_on_deleted_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
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
    t.integer  "roles_mask",             default: 1
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
    t.integer  "invitations_count",      default: 0
    t.string   "title"
    t.integer  "team_id"
    t.boolean  "notify",                 default: false
    t.integer  "neg_balance"
    t.integer  "pos_balance"
    t.datetime "last_alert_at"
    t.integer  "neg_balance_cnt"
    t.integer  "pos_balance_cnt"
    t.integer  "neg_balance_lcnt"
    t.integer  "pos_balance_lcnt"
    t.integer  "neg_balance_l"
    t.integer  "pos_balance_l"
    t.integer  "neg_balance_l_cnt"
    t.integer  "pos_balance_l_cnt"
    t.decimal  "win_rate"
    t.decimal  "average_deal_size"
    t.float    "cycle_time"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["team_id"], name: "index_users_on_team_id", using: :btree

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
  end

  add_index "values", ["company_id", "field_id"], name: "index_values_on_company_id_and_field_id", using: :btree
  add_index "values", ["option_id"], name: "index_values_on_option_id", using: :btree
  add_index "values", ["subject_type", "subject_id"], name: "index_values_on_subject_type_and_subject_id", using: :btree
  add_index "values", ["value_object_type", "value_object_id"], name: "index_values_on_value_object_type_and_value_object_id", using: :btree

  add_foreign_key "users", "teams"
end
