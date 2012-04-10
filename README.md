# ice_cube - easy date expansion

[![Build Status](https://secure.travis-ci.org/seejohnrun/ice_cube.png)](http://travis-ci.org/seejohnrun/ice_cube)

``` bash
gem install ice_cube
```

ice_cube is a ruby library for easily handling repeated events (schedules).
The API is modeled after iCalendar repeated dates.  The power lies in the
ability to specify multiple rules and dates, and have ice_cube quickly figure
out whether the schedule falls on a certain date (.occurs_on?), or what dates
it occurs on (.occurrences, .first, .all_occurrences)

Imagine you want:

> Every friday the 13th that falls in October

You would write:

``` ruby
schedule.add_recurrence_rule Rule.yearly.day_of_month(13).day(:friday).
  month_of_year(:october)
```

---

## Quick Introductions

* Presentation from Lone Star Ruby Conf -
  http://seejohnrun.github.com/ice_cube/static/lsrc_ice_cube.pdf
* Quick Introduction -
  http://seejohnrun.github.com/ice_cube/static/ice_cube_ruby_nyc.pdf
* Website -
  http://seejohnrun.github.com/ice_cube/

---

With ice_cube, you can specify (in order of precendence)

* Exception Dates - To specifically exclude from a schedule
* Recurrence Dates - To specifically include in a schedule
* Exception Rules - Rules on how to exclude recurring dates in a schedule
* Recurrence Rules - Rules on how to include recurring dates in a schedule

EX: Specifying a exception/recurrence date:

``` ruby
schedule = Schedule.new(start_date)
schedule.add_recurrence_date(Time.now)
schedule.add_exception_date(Time.now + 1)

# list all occurrences from start_date to end_date
occurrences = schedule.occurrences(end_date) # [Time.now]

# or all of the occurrences
occurrences = schedule.all_occurrences # [Time.now]

# or check just a single time
schedule.occurs_at?(Time.now) # true

# or check just a single day
schedule.occurs_on?(Date.new) # true

# or check whether it occurs between two dates
schedule.occurs_between?(Time.now, Time.now + 30.days) # true
schedule.occurs_between?(Time.now + 3.days, Time.now + 30.days) # false

# or the first (n) occurrences
schedule.first(n) # [Time.now]
schedule.first # Time.now

# or the next occurrence
schedule.next_occurrence([from_date]) # defaults to Time.now
schedule.remaining_occurrences
schedule.next_occurrences(3, [from_date])

# or give the schedule a duration and ask if occurring_at?
schedule = Schedule.new(Time.now, :duration => 3600)
schedule.add_recurrence_rule Rule.daily
schedule.occurring_at?(Time.now + 1800) # true

# you can also give schedules a solidified end_time
schedule = Schedule.new(Time.now, :end_time => Time.now + 3600)
schedule.add_recurrence_rule Rule.daily
schedule.occurs_at?(Time.now + 3601) # false

# Or take control
schedule = Schedule.new
schedule.add_recurrence_rule Rule.daily
schedule.each_occurrence { |t| puts t }
```

The reason that schedules have durations and not individual rules, is to
maintain compatability with the ical
RFC: http://www.kanzaki.com/docs/ical/rrule.html

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

ice_cube can provide ical or string representations of individual rules.

``` ruby
rule = Rule.daily(2).day_of_week(:tuesday => [1, -1], :wednesday => [2])

rule.to_ical # 'FREQ=DAILY;INTERVAL=2;BYDAY=1TU,-1TU,2WE'

rule.to_s # 'Every 2 days on the last and 1st Tuesdays and the 2nd Wednesday'
```

---

All rules are based off of the schedule's start date.
Individual rules may optionally specify an until date, which is a date that
that individual rule is no longer effective, or a count (which is how many
times maximum you want the rule to be effective)

---

## Some types of Rules

There are many types of recurrence rules that can be added to a schedule:

### Daily

``` ruby
# every day
schedule.add_recurrence_rule Rule.daily

# every third day
schedule.add_recurrence_rule Rule.daily(3)
```

### Weekly

``` ruby
# every week
schedule.add_recurrence_rule Rule.weekly

# every other week on monday and tuesday
schedule.add_recurrence_rule Rule.weekly(2).day(:monday, :tuesday)

# for programatic convenience (same as above)
schedule.add_recurrence_rule Rule.weekly(2).day(1, 2)
```

### Monthly (by day of month)

``` ruby
# every month on the first and last days of the month
schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)

# every other month on the 15th of the month
schedule.add_recurrence_rule Rule.monthly(2).day_of_month(15)
```

### Monthly (by day of week)

``` ruby
# every month on the first and last tuesdays of the month
schedule.add_recurrence_rule Rule.monthly.day_of_week(:tuesday => [1, -1])

# every other month on the first monday and last tuesday
schedule.add_recurrence_rule Rule.monthly(2).day_of_week(
  :monday => [1],
  :tuesday => [-1]
)

# for programatic convenience (same as above)
schedule.add_recurrence_rule Rule.monthly(2).day_of_week(1 => [1], 2 => [-1])
```

### Yearly (by day of year)

``` ruby
# every year on the 100th day from the beginning and end of the year
schedule.add_recurrence_rule Rule.yearly.day_of_year(100, -100)

# every fourth year on new year's eve
schedule.add_recurrence_rule Rule.yearly(4).day_of_year(-1)
```

### Yearly (by month of year)

``` ruby
# every year on the same day as start_date but in january and february
schedule.add_recurrence_rule Rule.yearly.month_of_year(:january, :februrary)

# every third year in march
schedule.add_recurrence_rule Rule.yearly(3).month_of_year(:march)

# for programatic convenience (same as above)
schedule.add_recurrence_rule Rule.yearly(3).month_of_year(3)
```

### Hourly (by hour of day)

``` ruby
# every hour on the same minute and second as start date
schedule.add_recurrence_rule Rule.hourly

# every other hour, on mondays
schedule.add_recurrence_rule Rule.hourly(2).day(:monday)
```

### Minutely (by minute of hour)

``` ruby
# every 10 minutes
schedule.add_recurrence_rule Rule.minutely(10)

# every hour and a half, on the last tuesday of the month
schedule.add_recurrence_rule Rule.minutely(90).day_of_week(:tuesday => [-1])
```

### Secondly (by second of minute)

``` ruby
# every second
schedule.add_recurrence_rule Rule.secondly

# every 15 seconds between 12 - 12:59
schedule.add_recurrence_rule Rule.secondly(15).hour_of_day(12)
```

---

## Contributors

* Mat Brown - mat@patch.com
* Philip Roberts
* @sakrafd

---

## Issues?

Use the GitHub issue tracker

## Contributing

* Contributions are welcome - I use GitHub for issue
	tracking (accompanying failing tests are awesome) and feature requests
* Submit via fork and pull request (include tests)
* If you're working on something major, shoot me a message beforehand

---

### License

(The MIT License)

Copyright © 2010-2012 John Crepezzi

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the ‘Software’), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
