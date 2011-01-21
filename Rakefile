require 'rake/testtask'

task :default => :test

desc 'Run tests.'
Rake::TestTask.new(:test) do |task|
  task.test_files = FileList['test/*_test.rb']
  task.verbose = true
end

