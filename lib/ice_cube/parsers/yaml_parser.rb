require "yaml"

module IceCube
  class YamlParser < HashParser
    SERIALIZED_START = /start_(?:time|date): .+(?<tz>(?:-|\+)\d{2}:\d{2})$/

    attr_reader :hash

    def initialize(yaml)
      # Ruby 2.6-3.0 use positional args, Ruby 3.1+ uses keyword args for YAML.safe_load
      @hash = if RUBY_VERSION < "3.1"
        YAML.safe_load(yaml, [Date, Symbol, Time], [], true)
      else
        YAML.safe_load(yaml, permitted_classes: [Date, Symbol, Time], aliases: true)
      end
      yaml.match SERIALIZED_START do |match|
        start_time = hash[:start_time] || hash[:start_date]
        TimeUtil.restore_deserialized_offset start_time, match[:tz]
      end
    end
  end
end
