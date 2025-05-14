require 'sequel'
require 'bcrypt'
require 'dotenv/load'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

password_hash = BCrypt::Password.create('adminadmin')
DB[:users].insert_conflict(
  target: :username,
  update: { password: Sequel[:excluded][:password] }
).insert(
  username: 'admin',
  password: password_hash
)
puts 'Seed user created or already exists.'
