source "https://rubygems.org"
gemspec

compatible_rails_versions = [
  ">= 3.0.0",
  ("<5" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2"))
].compact

gem "activesupport", (ENV["RAILS_VERSION"] || compatible_rails_versions), require: false
gem "i18n", require: false
gem "tzinfo", require: false # only needed explicitly for RAILS_VERSION=3
