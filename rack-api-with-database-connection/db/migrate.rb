require 'sequel'
require 'dotenv/load'
require 'pry'

DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

Dir.glob(File.expand_path('migrate/*.sql', __dir__)).sort.each do |file|
  DB.run(File.read(file))
  puts "Migration executed: #{File.basename(file)}"
end
