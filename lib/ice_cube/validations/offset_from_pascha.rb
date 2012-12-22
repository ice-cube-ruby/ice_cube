module IceCube

  module Validations::OffsetFromPascha

    def offset_from_pascha(offset)

      validations_for(:offset_from_pascha) << Validation.new(offset)

      clobber_base_validations(:month, :day, :wday)
      self
    end

    class Validation

      attr_reader :offset

      StringBuilder.register_formatter(:offset_from_pascha) do |entries|
        str = "#{StringBuilder.sentence(entries)} days "
        str << (entries.first > 0 ? "after" : "before")
        #str << "after"
        str << " Pascha"
        str
      end

      def initialize(offset)
        @offset = offset
      end

      def type
        :day
      end

      def build_s(builder)
        builder.piece(:offset_from_pascha) << offset#StringBuilder.nice_number(offset)
      end

      def build_hash(builder)
        builder.validations_array(:offset_from_pascha) << offset
      end

      def build_ical(builder)
        #builder['BYYEARDAY'] << day
      end

      def validate(time, schedule)
        pascha = TimeUtil.date_of_pascha(time.year)
        if pascha + offset < time.to_date
          pascha = TimeUtil.date_of_pascha(time.year + 1) 
        end
        the_day = pascha + offset
        # compute the diff
        diff = the_day - time.to_date
        diff
      end

    end

  end

end
