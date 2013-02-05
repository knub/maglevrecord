require "rubygems"
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/test*.rb"
  t.ruby_opts << "--stone test"
end

desc "Run tests"
task :default => :test
