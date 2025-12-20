source "https://rubygems.org"
gemspec

compatible_rails_versions = [
  ">= 3.0.0",
  ("<5" if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("2.2.2"))
].compact

gem "activesupport", (ENV["RAILS_VERSION"] || compatible_rails_versions), require: false
gem "i18n", require: false
gem "tzinfo", require: false # only needed explicitly for RAILS_VERSION=3

gem "base64", require: false     # remove base64 deprecation warnings for Ruby 3.3+
gem "bigdecimal", require: false # remove bigdecimal deprecation warnings for Ruby 3.3+
gem "mutex_m", require: false    # ActiveSupport dependency on Ruby 3.4+
gem "ostruct", require: false    # remove ostruct deprecation warnings for Ruby 3.4+
gem "logger", require: false     # remove logger deprecation warnings for Ruby 3.4+
gem "benchmark", require: false  # remove benchmark deprecation warnings for Ruby 3.4+
