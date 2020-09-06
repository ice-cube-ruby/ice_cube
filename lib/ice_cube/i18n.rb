require 'ice_cube/null_i18n'

module IceCube
  module I18n

    LOCALES_PATH = File.expand_path(File.join('..', '..', '..', 'config', 'locales'), __FILE__)

    def self.t(*args)
      if args.count == 1
        args[0].is_a?(Hash) ? backend.t(**args[0]) : backend.t(args[0])
      else
        args[1].is_a?(Hash) ? backend.t(args[0], **args[1]) : backend.t(args[0])
      end
    end

    def self.l(*args)
      args[1].is_a?(Hash) ? backend.l(args[0], **args[1]) : backend.l(args[0])
    end

    def self.backend
      @backend ||= detect_backend!
    end

    def self.detect_backend!
      ::I18n.load_path += Dir[File.join(LOCALES_PATH, '*.yml')]
      ::I18n
    rescue NameError
      NullI18n
    end
  end
end
