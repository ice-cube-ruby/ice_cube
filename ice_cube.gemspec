lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ice_cube/version"

Gem::Specification.new do |s|
  s.name = "ice_cube"
  s.summary = "Ruby Date Recurrence Library"
  s.description = "ice_cube is a recurring date library for Ruby.  It allows for quick, programatic expansion of recurring date rules."
  s.author = "John Crepezzi"
  s.email = "john@crepezzi.com"
  s.homepage = "https://ice-cube-ruby.github.io/ice_cube/"
  s.license = "MIT"

  s.metadata["changelog_uri"] = "https://github.com/ice-cube-ruby/ice_cube/blob/master/CHANGELOG.md"
  s.metadata["wiki_uri"] = "https://github.com/ice-cube-ruby/ice_cube/wiki"

  s.version = IceCube::VERSION
  s.platform = Gem::Platform::RUBY
  s.files = Dir["lib/**/*.rb", "config/**/*.yml"]
  s.require_paths = ["lib"]

  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", "> 3")
  s.add_development_dependency("standard")
  s.add_development_dependency("benchmark")
end
