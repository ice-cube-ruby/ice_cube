module IceCube

  class StringBuilder

    attr_writer :base

    def initialize
      @types = {}
    end

    def piece(type, prefix = nil, suffix = nil)
      @types[type] ||= []
    end

    def to_s
      @types.each_with_object(@base || '') do |(type, segments), str|
        if f = self.class.formatter(type)
          str << ' ' << f.call(segments)
        else
          next if segments.empty?
          str << ' ' << self.class.sentence(segments)
        end
      end
    end

    def self.formatter(type)
      @formatters[type]
    end

    def self.register_formatter(type, &formatter)
      @formatters ||= {}
      @formatters[type] = formatter
    end

    module Helpers

      # influenced by ActiveSupport's to_sentence
      def sentence(array)
        case array.length
        when 0 ; ''
        when 1 ; array[0].to_s
        when 2 ; "#{array[0]} and #{array[1]}"
        else ; "#{array[0...-1].join(', ')}, and #{array[-1]}"
        end
      end

      def nice_number(number)
        literal_ordinal(number) || ordinalize(number)
      end

      def ordinalize(number)
        "#{number}#{ordinal(number)}"
      end

      def literal_ordinal(number)
        I18n.t("ice_cube.integer.literal_ordinals")[number]
      end

      def ordinal(number)
        ord = I18n.t("ice_cube.integer.ordinals")[number] ||
          I18n.t("ice_cube.integer.ordinals")[number % 10] ||
          I18n.t('ice_cube.integer.ordinals')[:default]
        number >= 0 ? ord : I18n.t("ice_cube.integer.negative", ordinal: ord)
      end

    end

    extend Helpers

  end

end
