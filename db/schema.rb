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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130702175910) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "custom_fields", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "custom_field_id"
    t.string   "label"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "custom_fields", ["survey_id"], :name => "index_custom_fields_on_survey_id"

  create_table "leads", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.string   "response_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "status_id",   :default => 4
  end

  add_index "leads", ["survey_id"], :name => "index_leads_on_survey_id"
  add_index "leads", ["user_id"], :name => "index_leads_on_user_id"

  create_table "survey_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "survey_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "survey_users", ["survey_id"], :name => "index_survey_users_on_survey_id"
  add_index "survey_users", ["user_id"], :name => "index_survey_users_on_user_id"

  create_table "surveys", :force => true do |t|
    t.integer  "activity_type_id"
    t.string   "title"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "survey_id"
    t.integer  "campaign_id"
  end

  add_index "surveys", ["activity_type_id"], :name => "index_surveys_on_activity_type_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
