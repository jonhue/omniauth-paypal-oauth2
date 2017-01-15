# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'omniauth', 'paypal_oauth2', 'version'), __FILE__)

Gem::Specification.new do |gem|
    gem.name          = 'omniauth-paypal-oauth2'
    gem.version       = OmniAuth::PayPalOauth2::VERSION
    gem.license       = 'MIT'
    gem.summary       = %q{A PayPal OAuth2 strategy for OmniAuth 1.x}
    gem.description   = %q{A PayPal OAuth2 strategy for OmniAuth 1.x}
    gem.authors       = ['Jonas Hübotter']
    gem.email         = ['jonas@slooob.com']
    gem.homepage      = 'https://github.com/jonhue/omniauth-paypal-oauth2'

    gem.files         = `git ls-files`.split("\n")
    gem.require_paths = ["lib"]

    gem.required_ruby_version = '>= 2.0'

    gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.3.1'
    gem.add_runtime_dependency 'json', '~> 1.7', '>= 1.7.7'

    gem.add_development_dependency 'rspec', '~> 2.99.0'
    gem.add_development_dependency 'rake'
end
