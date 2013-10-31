$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'rails_tuneup'
