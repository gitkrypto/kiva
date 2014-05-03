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

ActiveRecord::Schema.define(version: 20140503181054) do

  create_table "blocks", force: true do |t|
    t.integer  "height"
    t.string   "generator_id"
    t.decimal  "total_amount_nqt"
    t.decimal  "total_fee_nqt"
    t.decimal  "total_pos_reward_nqt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: true do |t|
    t.integer  "block_id"
    t.string   "native_id"
    t.decimal  "amount_nqt"
    t.decimal  "fee_nqt"
    t.string   "sender_id"
    t.string   "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
