require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

NAME = "awesome_email"
SUMMARY = %Q{Rails ActionMailer with HTML layouts, inline CSS and entity substitution.}
HOMEPAGE = "http://github.com/grimen/#{NAME}/tree/master"
AUTHORS = ["imedo GmbH"]
EMAIL = "entwickler@imedo.de"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = NAME
    gem.summary = SUMMARY
    gem.description = SUMMARY
    gem.homepage = HOMEPAGE
    gem.authors = AUTHORS
    gem.email = EMAIL
    
    gem.require_paths = %w{lib}
    gem.files = %w(MIT-LICENSE README.textile Rakefile) + Dir.glob(File.join('{lib,rails,test}', '**', '*'))
    gem.executables = %w()
    gem.extra_rdoc_files = %w{README.textile}
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc %Q{Run unit tests for "#{NAME}".}
task :default => :test

desc %Q{Run unit tests for "#{NAME}".}
Rake::TestTask.new(:test) do |test|
  test.libs << ['lib', 'test']
  test.pattern = File.join('test', '**', '*_test.rb')
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  desc %Q{Analyze test coverage of the code in "#{NAME}".}
  Rcov::RcovTask.new do |t|
    t.libs << 'test'
    t.test_files = FileList[File.join('test', '**', '*_test.rb')]
    t.verbose = true
  end
rescue LoadError
  puts "RCov is not available. In order to run RCov, you must install it: sudo gem install spicycode-rcov -s http://gems.github.com"
end

desc %Q{Generate documentation for "#{NAME}".}
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = NAME
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=UTF-8'
  rdoc.rdoc_files.include('README.textile')
  rdoc.rdoc_files.include(File.join('lib', '**', '*.rb'))
end