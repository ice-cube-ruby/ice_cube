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
      string = @base || ''
      @types.each do |type, segments|
        if f = self.class.formatter(type)
          current = f.call(segments)
        else
          next if segments.empty?
          current = self.class.sentence(segments)
        end
        f = I18n.t('ice_cube.string.format')[type] ? type : 'default'
        string = I18n.t("ice_cube.string.format.#{f}", rest: string, current: current)
      end
      string
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
        when 2 ; "#{array[0]}#{I18n.t('ice_cube.array.two_words_connector')}#{array[1]}"
        else ; "#{array[0...-1].join(I18n.t('ice_cube.array.words_connector'))}#{I18n.t('ice_cube.array.last_word_connector')}#{array[-1]}"
        end
      end

      def nice_number(number)
        literal_ordinal(number) || ordinalize(number)
      end

      def ordinalize(number)
        I18n.t('ice_cube.integer.ordinal', number: number, ordinal: ordinal(number))
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
