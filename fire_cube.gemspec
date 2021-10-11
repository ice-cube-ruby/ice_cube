# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ice_cube/version'

Gem::Specification.new do |s|
  s.name          = 'fire_cube'
  s.summary       = 'Ruby Date Recurrence Library'
  s.description   = 'fire_cube is a fork of the excellent recurring date library for Ruby, ice_cube, by seejohnrun.  It allows for quick, programatic expansion of recurring date rules.'
  s.author        = 'Jon Pascoe'
  s.email         = 'jon.pascoe@me.com'
  s.homepage      = 'https://github.com/configua/fire_cube'
  s.license       = 'MIT'

  s.version       = IceCube::VERSION
  s.platform      = Gem::Platform::RUBY
  s.files         = Dir['lib/**/*.rb', 'config/**/*.yml']
  s.test_files    = Dir.glob('spec/*.rb')
  s.require_paths = ['lib']

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '> 3')
end
