# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'omniauth/paypal_oauth2/version'

Gem::Specification.new do |s|
  s.name     = 'omniauth-paypal-oauth2'
  s.version  = '1.4.4'
  s.authors  = ['Jonas Hübotter']
  s.email    = ['jonas.huebotter@gmail.com']
  s.summary  = 'A PayPal OAuth2 strategy for OmniAuth 1.x'
  s.homepage = 'http://omniauth-paypal-oauth2.jonhue.me'
  s.license  = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'omniauth-oauth2', '~> 1.4.0'

  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rake'
end
