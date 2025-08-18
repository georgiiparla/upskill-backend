## File: Rakefile

require 'sqlite3'
require_relative './db/connection'

namespace :db do
  desc "Setup the database: create, load schema, and seed"
  task :setup do
    puts "Creating database file..."
    DB
    
    puts "Loading schema..."
    Rake::Task['db:schema'].invoke

    puts "Seeding data..."
    Rake::Task['db:seed'].invoke
    
    puts "Database setup complete."
  end

  desc "Load the database schema"
  task :schema do
    sql = File.read('db/schema.sql')
    DB.execute_batch(sql)
    puts "Schema loaded."
  end

  desc "Seed the database with initial data"
  task :seed do
    sql = File.read('db/seeds.sql')
    DB.execute_batch(sql)
    puts "Data seeded."
  end
end