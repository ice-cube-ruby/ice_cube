spec = Gem::Specification.new do |s|
  
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.description = 'ice_cube is a recurring date library for Ruby.  It allows for quick, programatic expansion of recurring date rules.'
  s.email = 'john@crepezzi.com'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.homepage = 'http://github.com/seejohnrun/ice_cube'
  s.name = 'ice_cube'  
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Ruby Date Recurrence Library'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = '0.2.3'

end