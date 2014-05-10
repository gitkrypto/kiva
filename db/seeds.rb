# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Generate all Stakeholder accounts
def add_stakeholder_accounts
  puts "Generating Stakeholder Accounts"
  ActiveRecord::Base.transaction do
    accounts  = Fuzzer::Genesis.accounts
    accounts  = accounts.slice(0..20) if Rails.env != 'production'
    
    accounts.each_with_index do |native_id, index| 
      puts "Adding Stakeholder Account #{index} ..." if index % 100 == 0
      passphrase  = Fuzzer::Genesis.keys[index] 
      Account.create!({:native_id => native_id, :passphrase => passphrase})
    end
  end
end

# Generate all accounts in the accounts.csv monster list
def add_csv_accounts
  puts "Generating Accounts From accounts.csv"
  count    = 0
  accounts = CSV.read("#{Rails.root}/lib/nxt/accounts.csv")
  accounts = accounts.slice(0..600) if Rails.env != 'production'  
  accounts.each_slice(100) do |arr|
    puts "Adding Account #{count} ..." if count % 100 == 0
    ActiveRecord::Base.transaction do
      arr.each do |row|
        count += 1
        Account.create!({:native_id => row[0], :passphrase => row[1]})
      end
    end
  end
end

add_stakeholder_accounts
add_csv_accounts