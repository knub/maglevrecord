require 'rake/testtask'
require 'bundler/gem_tasks'
$LOAD_PATH << "./lib"
require 'lib/tasks/maglev_record'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**test*.rb"
  t.ruby_opts << "-rubygems --stone test"
end

desc "Run tests"
task :default => :test
