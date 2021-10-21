require "ice_cube/null_i18n"

module IceCube
  module I18n
    LOCALES_PATH = File.expand_path(File.join("..", "..", "..", "config", "locales"), __FILE__)

    class << self
      delegate :t, :l, to: :backend
    end

    def self.backend
      @backend ||= detect_backend!
    end

    def self.detect_backend!
      rails_i18n_index = ::I18n.load_path.index { |item| item =~ /rails_i18n/ } || -1
      ::I18n.load_path.insert(rails_i18n_index, *Dir[File.join(LOCALES_PATH, "*.yml")])
      ::I18n
    rescue NameError
      NullI18n
    end
  end
end
