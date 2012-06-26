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

ActiveRecord::Schema.define(:version => 20120625185505) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "events", :force => true do |t|
    t.integer  "venue_id"
    t.string   "name"
    t.string   "age_restriction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "begins_at"
    t.text     "description"
    t.string   "marker"
    t.string   "url"
    t.string   "price"
    t.string   "state"
  end

  create_table "posts", :force => true do |t|
    t.string   "url"
    t.text     "block"
    t.integer  "venue_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "marker"
    t.integer  "event_count"
    t.datetime "remove_on"
  end

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "site_url"
    t.string   "event_list_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.string   "parse_type"
  end

end
