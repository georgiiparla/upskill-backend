ENV['RACK_ENV'] = 'test'
ENV['JWT_SECRET'] = 'test_secret_for_specs'


require 'dotenv'
Dotenv.load('.env.test')

require 'rspec'
require 'rack/test'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'

# Load application config
require_relative '../config/app_config'

# Load models
Dir["#{__dir__}/../app/models/*.rb"].each { |file| require file }

# Load controllers
require_relative '../app/controllers/application_controller'
Dir["#{__dir__}/../app/controllers/*.rb"].each { |file| require file }

# Setup in-memory database
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.verbose = false
load "#{__dir__}/../db/schema.rb"

module RSpecMixin
  include Rack::Test::Methods

  def app
    # You can return the specific controller class or a Rack::Builder
    # For integration tests, we might want the full stack, but for controller specs, just the controller is often enough.
    # However, since controllers might inherit or use middleware, let's map the specific controller in the spec
    described_class
  end
end

require 'factory_bot'

RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
  
  config.before(:each) do
    # Clear database before each test
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
    ActiveRecord::Base.descendants.each do |model|
      model.delete_all if model.respond_to?(:delete_all)
    end
    ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
  end
end
