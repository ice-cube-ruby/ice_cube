require File.dirname(__FILE__) + '/lib/ice_cube/version'

spec = Gem::Specification.new do |s|
  
  s.name = 'ice_cube'  
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.add_development_dependency('active_support', '>= 3.0.0')
  s.add_development_dependency('tzinfo')
  s.description = 'ice_cube is a recurring date library for Ruby.  It allows for quick, programatic expansion of recurring date rules.'
  s.email = 'john@crepezzi.com'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.homepage = 'http://seejohnrun.github.com/ice_cube/'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Ruby Date Recurrence Library'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = IceCube::VERSION
  s.rubyforge_project = "ice-cube"

end
