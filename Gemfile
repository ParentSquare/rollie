# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

not_jruby = %i[ruby mingw x64_mingw].freeze

gem 'bundler', '>= 1.17', '< 3'
gem 'byebug', platforms: not_jruby
gem 'irb', '~> 1.0'
gem 'redcarpet', '~> 3.5', platforms: not_jruby
gem 'simplecov', '>= 0.17.1'
gem 'simplecov-cobertura'
gem 'yard', '~> 0.9.26', platforms: not_jruby

if RUBY_ENGINE == 'truffleruby'
  # Truffleruby currently crashes due to a missing method
  # when using redis >= 4.2.3
  # NoMethodError: undefined method `wait_writable' for #<Redis::Connection::TCPSocket:fd 17>
  # Needs further investigation
  gem 'redis', '< 4.2.3'
elsif ENV['REDIS_VERSION']
  gem 'redis', ENV['REDIS_VERSION']
end
