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

ActiveRecord::Schema.define(version: 20140503175909) do

  create_table "accounts", force: true do |t|
    t.string  "native_id"
    t.decimal "balance_nqt"
    t.string  "public_key"
  end

  create_table "blocks", force: true do |t|
    t.string  "native_id"
    t.integer "account_id"
    t.integer "timestamp"
    t.integer "height"
    t.integer "payload_length"
    t.string  "payload_hash"
    t.string  "generation_signature"
    t.string  "block_signature"
    t.decimal "base_target"
    t.decimal "cumulative_difficulty"
    t.decimal "total_amount_nqt"
    t.decimal "total_fee_nqt"
    t.decimal "total_pos_nqt"
    t.integer "version"
    t.integer "previous_block"
    t.integer "next_block"
  end

  create_table "transactions", force: true do |t|
    t.string  "native_id"
    t.integer "timestamp"
    t.integer "block_id"
    t.integer "sender"
    t.integer "recipient"
    t.decimal "amount_nqt"
    t.decimal "fee_nqt"
  end

end
