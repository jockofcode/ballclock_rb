# require File.expand_path("../../config/environment", __FILE__)
# require 'rspec/rails'
require 'rspec'

RSpec.configure do |config|
  # run each example in a transaction
  # config.use_transactional_fixtures = true
  # randomize the test order
  config.order = "random"
end
