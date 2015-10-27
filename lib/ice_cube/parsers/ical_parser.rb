module IceCube
  class IcalParser
    def self.schedule_from_ical(ical_string, options = {})
      data = {}
      ical_string.each_line do |line|
        (property, value) = line.split(':')
        (property, tzid) = property.split(';')
        case property
        when 'DTSTART'
          data[:start_time] = Time.parse(value)
        when 'DTEND'
          data[:end_time] = Time.parse(value)
        when 'EXDATE'
          data[:extimes] ||= []
          data[:extimes] += value.split(',').map{|v| Time.parse(v)}
        when 'DURATION'
          data[:duration] # FIXME
        when 'RRULE'
          data[:rrules] ||= []
          data[:rrules] += [rule_from_ical(value)]
        end
      end
      Schedule.from_hash data
    end

    def self.rule_from_ical(ical)
      params = { validations: { } }

      ical.split(';').each do |rule|
        (name, value) = rule.split('=')
        value.strip!
        case name
        when 'FREQ'
          params[:freq] = value.downcase
        when 'INTERVAL'
          params[:interval] = value.to_i
        when 'COUNT'
          params[:count] = value.to_i
        when 'UNTIL'
          params[:until] = Time.parse(value).utc
        when 'WKST'
          params[:wkst] = TimeUtil.ical_day_to_symbol(value)
        when 'BYSECOND'
          params[:validations][:second_of_minute] = value.split(',').collect(&:to_i)
        when 'BYMINUTE'
          params[:validations][:minute_of_hour] = value.split(',').collect(&:to_i)
        when 'BYHOUR'
          params[:validations][:hour_of_day] = value.split(',').collect(&:to_i)
        when 'BYDAY'
          dows = {}
          days = []
          value.split(',').each do |expr|
            day = TimeUtil.ical_day_to_symbol(expr.strip[-2..-1])
            if expr.strip.length > 2  # day with occurence
              occ = expr[0..-3].to_i
              dows[day].nil? ? dows[day] = [occ] : dows[day].push(occ)
              days.delete(TimeUtil.sym_to_wday(day))
            else
              days.push TimeUtil.sym_to_wday(day) if dows[day].nil?
            end
          end
          params[:validations][:day_of_week] = dows unless dows.empty?
          params[:validations][:day] = days unless days.empty?
        when 'BYMONTHDAY'
          params[:validations][:day_of_month] = value.split(',').collect(&:to_i)
        when 'BYMONTH'
          params[:validations][:month_of_year] = value.split(',').collect(&:to_i)
        when 'BYYEARDAY'
          params[:validations][:day_of_year] = value.split(',').collect(&:to_i)
        when 'BYSETPOS'
        else
          raise "Invalid or unsupported rrule command: #{name}"
        end
      end

      params[:interval] ||= 1

      # WKST only valid for weekly rules
      params.delete(:wkst) unless params[:freq] == 'weekly'

      rule = Rule.send(*params.values_at(:freq, :interval, :wkst).compact)
      rule.count(params[:count]) if params[:count]
      rule.until(params[:until]) if params[:until]
      params[:validations].each do |key, value|
        value.is_a?(Array) ? rule.send(key, *value) : rule.send(key, value)
      end

      rule
    end
  end
end
