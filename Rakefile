require 'rake/testtask'
require 'bundler/gem_tasks'
require 'logger'
$LOAD_PATH << './lib'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/{,**/}test*.rb"
  t.ruby_opts << "-W0 -rubygems --stone test"
end

desc "Run tests"

task :default => :test
