$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "rollie/version"

Gem::Specification.new do |s|
  s.name = "rollie"
  s.version = Rollie::VERSION
  s.license = "MIT"

  s.summary = "Generic rate limiter backed by Redis for efficient limiting using sliding windows."
  s.description = s.summary

  s.authors = ["Zach Davis"]
  s.email = "zldavis@gmail.com"
  s.homepage = "https://github.com/zldavis/rollie"

  s.files = ["lib/rollie.rb", "lib/rollie/rate_limiter.rb", "lib/rollie/redis_pool.rb", "lib/rollie/status.rb", "lib/rollie/version.rb"]

  s.require_paths = ["lib"]

  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency "redis", "~> 3.2", ">= 3.2.1"
  s.add_dependency "redis-namespace", "~> 1.5", ">= 1.5.2"
  s.add_dependency "connection_pool", "~> 2.2", ">= 2.2.0"
end
