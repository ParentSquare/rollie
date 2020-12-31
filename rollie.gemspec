# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'rollie/version'

Gem::Specification.new do |s|
  s.name = 'rollie'
  s.version = Rollie::VERSION
  s.license = 'MIT'

  s.summary = 'Generic rate limiter backed by Redis for efficient limiting using sliding windows.'
  s.description = s.summary

  s.authors = ['Zach Davis', 'Justin Howard']
  s.email = 'justin.howard@parentsquare.com'
  s.homepage = 'https://github.com/ParentSquare/rollie'

  s.files = `git ls-files -z`.split("\x0")
  s.test_files = `git ls-files -- test/*`.split("\n")

  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.4'

  s.add_dependency 'connection_pool', '>= 2.2.0'
  s.add_dependency 'redis', '>= 3.2.1'
  s.add_dependency 'redis-namespace', '>= 1.5.2'

  s.add_development_dependency 'rspec', '~> 3.8'
  s.add_development_dependency 'rubocop', '~> 1.7'
  s.add_development_dependency 'rubocop-rspec', '~> 2.1'
end
