# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'omniauth', 'paypal_oauth2', 'version'), __FILE__)

Gem::Specification.new do |gem|
    gem.name          = 'omniauth-paypal-oauth2'
    gem.version       = OmniAuth::PaypalOauth2::VERSION
    gem.license       = 'MIT'
    gem.summary       = 'A PayPal OAuth2 strategy for OmniAuth'
    gem.description   = 'A PayPal OAuth2 strategy for OmniAuth'
    gem.authors       = ['Jonas Hübotter']
    gem.email         = ['jonas@slooob.com']
    gem.homepage      = 'https://github.com/jonhue/omniauth-paypal-oauth2'

    gem.files         = `git ls-files`.split("\n")
    gem.require_paths = ['lib']

    gem.required_ruby_version = '>= 2.0'

    gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.4'
    gem.add_runtime_dependency 'json', '~> 1.7', '>= 1.7.7'

    gem.add_development_dependency 'rspec', '~> 3.5'
    gem.add_development_dependency 'rake'
end
