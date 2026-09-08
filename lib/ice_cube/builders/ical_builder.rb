module IceCube
  class IcalBuilder
    ICAL_DAYS = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    def initialize
      @hash = {}
    end

    def self.fixnum_to_ical_day(num)
      ICAL_DAYS[num]
    end

    def [](key)
      @hash[key] ||= []
    end

    # Build for a single rule entry
    def to_s
      arr = []
      if (freq = @hash.delete("FREQ"))
        arr << "FREQ=#{freq.join(",")}"
      end
      arr.concat(@hash.map do |key, value|
        if value.is_a?(Array)
          "#{key}=#{value.join(",")}"
        end
      end.compact)
      arr.join(";")
    end

    def self.ical_utc_format(time)
      time = time.dup.utc
      IceCube::I18n.l(time, format: "%Y%m%dT%H%M%SZ") # utc time
    end

    def self.ical_format(time, force_utc)
      time = time.dup.utc if force_utc

      # Keep the time zone. strftime would serialize the abbreviated zone name
      # (eg. EEST), which is not reversible, as the same abbreviation is shared
      # by several zones. This would result in issues in parsing.
      if time.respond_to?(:time_zone)
        return ";TZID=#{tzid_for(time.time_zone)}:#{IceCube::I18n.l(time, format: "%Y%m%dT%H%M%S")}" # local time specified
      end

      if time.utc?
        ":#{IceCube::I18n.l(time, format: "%Y%m%dT%H%M%SZ")}" # utc time
      else
        # Convert to UTC as TZID=+xxxx format is not recognized by JS libraries
        warn_missing_time_zone
        utc_time = time.dup.utc
        ":#{IceCube::I18n.l(utc_time, format: "%Y%m%dT%H%M%SZ")}" # converted to utc time
      end
    end

    # RFC 5545 leaves the TZID registry unspecified but points implementers at
    # the IANA (Olson) database, which is what other iCalendar implementations
    # expect. ActiveSupport zones may carry a Rails-specific label instead (eg.
    # "Eastern Time (US & Canada)"), so prefer the underlying IANA identifier;
    # ActiveSupport still resolves those, and everyone else can too.
    def self.tzid_for(zone)
      if zone.respond_to?(:tzinfo) && zone.tzinfo.respond_to?(:name)
        zone.tzinfo.name
      else
        zone.name
      end
    end

    # A schedule built from plain Time objects hits this on every serialization,
    # so warn once per process rather than once per occurrence.
    def self.warn_missing_time_zone
      return if @missing_time_zone_warned

      @missing_time_zone_warned = true
      warn "IceCube: Time object does not have timezone info. Coercing into UTC: #{caller(2..2).first}"
    end

    def self.ical_duration(duration)
      hours = duration / 3600
      duration %= 3600
      minutes = duration / 60
      duration %= 60
      repr = ""
      repr << "#{hours}H" if hours > 0
      repr << "#{minutes}M" if minutes > 0
      repr << "#{duration}S" if duration > 0
      "PT#{repr}"
    end
  end
end
