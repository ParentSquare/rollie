require "rake"
require "rdoc"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[lib]))
require "rollie/version"

def name
  "rollie"
end

def version
  Rollie::VERSION
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError; end

require "rdoc/task"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task :default => :spec