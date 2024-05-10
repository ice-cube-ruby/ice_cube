require "ice_cube/null_i18n"

module IceCube
  module I18n
    LOCALES_PATH = File.expand_path(File.join("..", "..", "..", "config", "locales"), __FILE__)

    def self.t(*args, **kwargs)
      backend.t(*args, **kwargs)
    end

    def self.l(*args, **kwargs)
      backend.l(*args, **kwargs)
    end

    def self.backend
      @backend ||= detect_backend!
    end

    def self.detect_backend!
      ::I18n.load_path += Dir[File.join(LOCALES_PATH, "*.yml")]
      ::I18n
    rescue NameError
      NullI18n
    end
  end
end
