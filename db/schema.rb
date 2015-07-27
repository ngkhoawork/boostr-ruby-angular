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

ActiveRecord::Schema.define(version: 20150727155338) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.integer  "company_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "website"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted_at"
    t.string   "client_type"
  end

  add_index "clients", ["deleted_at"], name: "index_clients_on_deleted_at", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "primary_contact_id"
    t.integer  "billing_contact_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "quantity"
    t.integer  "cost"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.integer  "client_id"
    t.integer  "company_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
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
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
