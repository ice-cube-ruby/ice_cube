require 'spec/rake/spectask'
require 'lib/ice_cube/version'
 
task :build => :test do
  system "gem build ice_cube.gemspec"
end

task :release => :build do
  system "gem push ice_cube-#{IceCube::VERSION}"
end
 
Spec::Rake::SpecTask.new(:test) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  fail_on_error = true # be explicit
end
 
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  fail_on_error = true # be explicit
end