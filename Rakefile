require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

system 'bundle'
system 'gem build omniauth-paypal-oauth2.gemspec'


RSpec::Core::RakeTask.new

task default: :spec
