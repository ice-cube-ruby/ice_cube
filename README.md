# ice_cube - Easy schedule expansion

[![Build Status][travis-ice_cube-png]][travis-ice_cube]

<a href="https://www.stripeme.com/pay/1lq0">
  <img alt="Pay" src="https://www.stripeme.com/pay.jpg" />
</a>

```bash
gem install ice_cube
```

ice_cube is a ruby library for easily handling repeated events (schedules).
The API is modeled after [iCalendar events][ical-3.6.1], in a pleasant Ruby
syntax. The power lies in the ability to specify multiple rules, and have
ice_cube quickly figure out whether the schedule falls on a certain date
(.occurs_on?), or what times it occurs at (.occurrences, .first,
.all_occurrences).

Imagine you want:

> Every friday the 13th that falls in October

You would write:

```ruby
schedule.add_recurrence_rule(
  Rule.yearly.day_of_month(13).day(:friday).month_of_year(:october)
)
```

---

## Quick Introductions

* [Presentation from Lone Star Ruby Conf][ice_cube-lone_star_pdf]
* [Quick Introduction][ice_cube-ruby_nyc_pdf]
* [Documentation Website][ice_cube-docs]

---

With ice_cube, you can specify (in increasing order of precendence):

* Recurrence Rules - Rules on how to include recurring times in a schedule
* Recurrence Times - To specifically include in a schedule
* Exception Times - To specifically exclude from a schedule

Example: Specifying a recurrence with an exception time:

```ruby
schedule = Schedule.new(now = Time.now) do |s|
  s.add_recurrence_rule(Rule.daily.count(3))
  s.add_exception_time(now + 1.day)
end

# list occurrences until end_time (end_time is needed for non-terminating rules)
occurrences = schedule.occurrences(end_time) # [now]

# or all of the occurrences (only for terminating schedules)
occurrences = schedule.all_occurrences # [now, now + 2.days]

# or check just a single time
schedule.occurs_at?(now + 1.day)  # false
schedule.occurs_at?(now + 2.days) # true

# or check just a single day
schedule.occurs_on?(Date.today) # true

# or check whether it occurs between two dates
schedule.occurs_between?(now, now + 30.days)          # true
schedule.occurs_between?(now + 3.days, now + 30.days) # false

# or the first (n) occurrences
schedule.first(2) # [now, now + 2.days]
schedule.first    # now

# or the last (n) occurrences (if the schedule terminates)
schedule.last(2) # [now + 1.day, now + 2.days]
schedule.last    # now + 2.days

# or the next occurrence
schedule.next_occurrence(from_time)     # defaults to Time.now
schedule.next_occurrences(3, from_time) # defaults to Time.now
schedule.remaining_occurrences          # for terminating schedules

# or the previous occurrence
schedule.previous_occurrence(from_time)
schedule.previous_occurrences(3, from_time)


# or give the schedule a duration and ask if occurring_at?
schedule = Schedule.new(now, :duration => 3600)
schedule.add_recurrence_rule Rule.daily
schedule.occurring_at?(now + 1800) # true
schedule.occurring_between?(t1, t2)

# using end_time also sets the duration 
schedule = Schedule.new(start = Time.now, :end_time => start + 3600)
schedule.add_recurrence_rule Rule.daily
schedule.occurring_at?(start + 3599) # true
schedule.occurring_at?(start + 3600) # false

# take control and use iteration
schedule = Schedule.new
schedule.add_recurrence_rule Rule.daily.until(Date.today + 30)
schedule.each_occurrence { |t| puts t }
```

The reason that schedules have durations and not individual rules, is to
maintain compatability with the ical
RFC: http://www.kanzaki.com/docs/ical/rrule.html

To limit schedules use `count` or `until` on the recurrence rules. Setting `end_time` on the schedule just sets the duration (from the start time) for each occurrence.

---

## Time Zones and ActiveSupport vs. Standard Ruby Time Classes

ice_cube works great without ActiveSupport but only supports the environment's
single "local" time zone (`ENV['TZ']`) or UTC. To correctly support multiple
time zones (especially for DST), you should require 'active_support/time'.

A schedule's occurrences will be returned in the same class and time zone as
the schedule's start_time. Schedule start times are supported as:

* Time.local (default when no time is specified)
* Time.utc
* ActiveSupport::TimeWithZone (with `Time.zone.now`, `Time.zone.local`, `time.in_time_zone(tz)`)
* DateTime (deprecated) and Date are converted to a Time.local

---

## Persistence

ice_cube implements its own hash-based .to_yaml, so you can quickly (and
safely) serialize schedule objects in and out of your data store

``` ruby
yaml = schedule.to_yaml
Schedule.from_yaml(yaml)

hash = schedule.to_hash
Schedule.from_hash(hash)

Schedule.from_yaml(yaml, :start_date_override => Time.now)
Schedule.from_hash(hash, :start_date_override => Time.now)
```

---

## Using your words

ice_cube can provide ical or string representations of individual rules, or the
whole schedule.

```ruby
rule = Rule.daily(2).day_of_week(:tuesday => [1, -1], :wednesday => [2])

rule.to_ical # 'FREQ=DAILY;INTERVAL=2;BYDAY=1TU,-1TU,2WE'

rule.to_s # 'Every 2 days on the last and 1st Tuesdays and the 2nd Wednesday'
```

---

## Some types of Rules

There are many types of recurrence rules that can be added to a schedule:

### Daily

```ruby
# every day
schedule.add_recurrence_rule Rule.daily

# every third day
schedule.add_recurrence_rule Rule.daily(3)
```

### Weekly

```ruby
# every week
schedule.add_recurrence_rule Rule.weekly

# every other week on monday and tuesday
schedule.add_recurrence_rule Rule.weekly(2).day(:monday, :tuesday)

# for programmatic convenience (same as above)
schedule.add_recurrence_rule Rule.weekly(2).day(1, 2)

# specifying a weekly interval with a different first weekday (defaults to Sunday)
schedule.add_recurrence_rule Rule.weekly(1, :monday)
```

### Monthly (by day of month)

```ruby
# every month on the first and last days of the month
schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)

# every other month on the 15th of the month
schedule.add_recurrence_rule Rule.monthly(2).day_of_month(15)
```

Monthly rules will use the nearest day at the end of the month if the month is
too short (e.g. February 28 for `day_of_month(31)`)

### Monthly (by day of Nth week)

```ruby
# every month on the first and last tuesdays of the month
schedule.add_recurrence_rule Rule.monthly.day_of_week(:tuesday => [1, -1])

# every other month on the first monday and last tuesday
schedule.add_recurrence_rule Rule.monthly(2).day_of_week(
  :monday => [1],
  :tuesday => [-1]
)

# for programmatic convenience (same as above)
schedule.add_recurrence_rule Rule.monthly(2).day_of_week(1 => [1], 2 => [-1])
```

### Yearly (by day of year)

```ruby
# every year on the 100th days from the beginning and end of the year
schedule.add_recurrence_rule Rule.yearly.day_of_year(100, -100)

# every fourth year on new year's eve
schedule.add_recurrence_rule Rule.yearly(4).day_of_year(-1)
```

### Yearly (by month of year)

```ruby
# every year on the same day as start_date but in january and february
schedule.add_recurrence_rule Rule.yearly.month_of_year(:january, :februrary)

# every third year in march
schedule.add_recurrence_rule Rule.yearly(3).month_of_year(:march)

# for programatic convenience (same as above)
schedule.add_recurrence_rule Rule.yearly(3).month_of_year(3)
```

### Hourly (by hour of day)

```ruby
# every hour on the same minute and second as start date
schedule.add_recurrence_rule Rule.hourly

# every other hour, on mondays
schedule.add_recurrence_rule Rule.hourly(2).day(:monday)
```

### Minutely (by minute of hour)

```ruby
# every 10 minutes
schedule.add_recurrence_rule Rule.minutely(10)

# every hour and a half, on the last tuesday of the month
schedule.add_recurrence_rule Rule.minutely(90).day_of_week(:tuesday => [-1])
```

### Secondly (by second of minute)

```ruby
# every second
schedule.add_recurrence_rule Rule.secondly

# every 15 seconds between 12:00 - 12:59
schedule.add_recurrence_rule Rule.secondly(15).hour_of_day(12)
```

---

## recurring_select

The team over at [GetJobber](http://getjobber.com/) have open-sourced
RecurringSelect, which makes working with IceCube easier in a Rails app
via some nice helpers.

Check it out at
https://github.com/GetJobber/recurring_select

---

## Contributors

* Mat Brown - mat@patch.com
* Philip Roberts
* @sakrafd
* Andrew Vit ([@avit][github-avit])

---

## Issues?

Use the GitHub [issue tracker][ice_cube-issues]

## Contributing

* Contributions are welcome - I use GitHub for issue
	tracking (accompanying failing tests are awesome) and feature requests
* Submit via fork and pull request (include tests)
* If you're working on something major, shoot me a message beforehand



[ical-3.6.1]: https://tools.ietf.org/html/rfc5545#section-3.6.1
[github-avit]: https://github.com/avit/
[travis-ice_cube]: http://travis-ci.org/seejohnrun/ice_cube
[travis-ice_cube-png]: https://secure.travis-ci.org/seejohnrun/ice_cube.png
[ice_cube-lone_star_pdf]: http://seejohnrun.github.com/ice_cube/static/lsrc_ice_cube.pdf
[ice_cube-ruby_nyc_pdf]: http://seejohnrun.github.com/ice_cube/static/ice_cube_ruby_nyc.pdf
[ice_cube-docs]: http://seejohnrun.github.com/ice_cube/
[ice_cube-issues]: https://github.com/seejohnrun/ice_cube/issues
