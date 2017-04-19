require File.join('bundler', 'setup')
require 'rspec'
require 'omniauth-oauth2'
Dir[File.expand_path('../support/**/*', __FILE__)].each { |f| require f }

RSpec.configure do |config|
    OmniAuth.config.test_mode = true
end
