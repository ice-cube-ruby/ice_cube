require 'rspec/core/rake_task'
require File.dirname(__FILE__) + '/lib/ice_cube/version'

task :build => :test do
  system "gem build ice_cube.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{IceCube::VERSION}"
  system "git push origin --tags"
  # push the gem
  system "gem push ice_cube-#{IceCube::VERSION}.gem"
end

RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  fail_on_error = true # be explicit
end
