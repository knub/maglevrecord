require 'rake/testtask'
require 'bundler/gem_tasks'
require 'logger'
$LOAD_PATH << './lib'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.name = 'testfast'
  t.test_files = FileList['test/**/test*.rb'] - FileList['test/**/test*.slow.rb']
  t.ruby_opts << "-W0 -rubygems --stone test"
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.name = 'testslow'
  t.test_files = FileList['test/**/test*.rb']
  t.ruby_opts << "-W0 -rubygems --stone test"
end

desc "Run tests"

task :default => :testfast
