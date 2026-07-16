require "ice_cube/null_i18n"

module IceCube
  LOCALES_PATH = File.expand_path(File.join("..", "..", "config", "locales"), __dir__)

  # rubocop:disable Naming/ConstantName
  I18n = begin
    require "i18n"
    ::I18n.load_path += Dir[File.join(LOCALES_PATH, "*.yml")]
    ::I18n
  rescue LoadError
    NullI18n
  end
  # rubocop:enable Naming/ConstantName
end
