require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

# Load application models for rake tasks
Dir["./app/models/*.rb"].each { |file| require file }

# Load custom rake tasks
Dir.glob('./lib/tasks/*.rake').each { |r| load r }