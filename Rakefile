#
# Copyright (c) 2009 El Draper, el@ejdraper.com
#
# Rakefile      Defines the Gem package specification
#
require "rubygems"
require "rake/gempackagetask"

# Define the cover-up gem spec
spec = Gem::Specification.new do |s|
  s.name = "cover-up"
  s.version = "0.2"
  s.author = "El Draper"
  s.email = "el@ejdraper.com"
  s.homepage = "http://github.com/edraper/cover-up"
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides dynamic coverage for Ruby code"
  s.files = FileList["{lib}/**/*"].to_a
end

# Setup the package task
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

desc "This runs the tests for the gem"
task :test do
  Dir.glob(File.join(File.dirname(__FILE__), "tests", "*_tests.rb")).each { |f| require f }
end