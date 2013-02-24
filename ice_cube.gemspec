require File.dirname(__FILE__) + '/lib/ice_cube/version'

Gem::Specification.new do |s|
  s.name          = 'ice_cube'
  s.summary       = 'Ruby Date Recurrence Library'
  s.description   = 'ice_cube is a recurring date library for Ruby.  It allows for quick, programatic expansion of recurring date rules.'
  s.author        = 'John Crepezzi'
  s.email         = 'john@crepezzi.com'
  s.homepage      = 'http://seejohnrun.github.com/ice_cube/'
  s.license       = 'MIT'

  s.version       = IceCube::VERSION
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir['lib/**/*.rb']
  s.test_files    = Dir.glob('spec/*.rb')
  s.require_paths = ['lib']
  s.has_rdoc      = true
  s.rubyforge_project = "ice-cube"

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('active_support', '>= 3.0.0')
  s.add_development_dependency('tzinfo')
end
