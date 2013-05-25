# Changelog

## 0.10.1 / 2013-05-17

* [BUGFIX]      Match time zone from schedule when finding times (#152)
* [BUGFIX]      Reliably calculate distance to same day in next month (#171)
* [ENHANCEMENT] Accept arrays in multiparameter DSL methods (#139)
* [BUGFIX]      Updating interval on a rule shouldn't leave duplicate validations (#158) (#157)
* [BUGFIX]      Allow Occurrence to work transparently with Arel (#168)
* [BUGFIX]      Raise errors for invalid input (#139)

## 0.10.0 / 2013-02-25

* [BUGFIX]      Fix monthly intervals to not skip short months (#105)
* [FEATURE]     Add support for `week_start` (@masquita) (#75)
* [BUGFIX]      Fix `occurring_between?` for zero-length occurrences at start boundary (#147)
* [ENHANCEMENT] Add block initialization, new schedule yields itself (#146)
* [ENHANCEMENT] Warn on use of DateTime and convert to local Time (#144)
* [BUGFIX]      Bug fix for count limit across multiple rules (#149)
* [BUGFIX]      Fix occurrences in DST transition (#150)
* [ENHANCEMENT] Start time counts as an implicit occurrence (no more empty schedule) (#135)
* [FEATURE]     Schedule occurrences have end times (#119)

## 0.9.3 / 2013-01-03

* [BUGFIX]      Match the subseconds of `start_time` when finding occurrences (#89)
* [FEATURE]     Duration is dependent upon `end_time` (#120)
* [ENHANCEMENT] Duration defaults to 0
* [BUGFIX]      Avoid microseconds when comparing times (#83)
* [BUGFIX]      Handle DateTime's lack of subseconds

## 0.9.2 / 2012-12-08

* [FEATURE]     Allow passing Time, Date, or DateTime to all calls

## 0.9.1 / 2012-10-19

* [BUGFIX]      A fix for removing `until` validations (#106)
* [BUGFIX]      A DST edge fix

## 0.9.0 / 2012-10-12

* [FEATURE]     Fix the effect on `end_time` on IceCube::Schedule (#99)
* [ENHANCEMENT] Remove `end_time` from `to_s` (#99)
* [BUGFIX]      Single recurrences now work properly with `conflict_with?` (#71)
* [BUGFIX]      Fix a bug with interval > 1 when using `occurrences_between` (#92)
* [BUGFIX]      Allow count, until removal by setting to nil (#94)
* [FEATURE]     Allow deserialization of string structures easily (#93)
* [BUGFIX]      Ignore usecs when creating Time.now for `*_occurrences` (#84)
* [BUGFIX]      DST bug fix (#98)
* [FEATURE]     Added `occurring_between?` (#88)

## 0.8.0

* Added support for WEEKST (thanks @devwout)

## 0.7.9

* Added INTERVAL to `to_ical` for all interval validations

## 0.7.8

* Bug fixes

## 0.7.7

* Added "Weekends" and "Weekdays" to day's `to_s`

## 0.7.6

* Support for `terminating?` and `conflicts_with?`

## 0.7.5

* Fix an issue with `occurrences_between` when using count (#54)

## 0.7.4

* NameError when serializing schedule with `end_time` (thanks @digx)

## 0.7.3

* Fix for time interval buckets (affects hour, minute, sec)

## 0.7.2

* Fix for interval to/from YAML issue

## 0.7.1

* Fix for comparing rules with nil

## 0.7.0

* Large rewrite, fixing a few small bugs and including some large optimizations to the spidering algo
* Support for `each_occurrence` which iterates as it builds forever

## 0.6.15

* Deserialize `until_date` properly in `to_hash` and `to_yaml` (thanks @promisedlandt)

## 0.6.14

* Fixed a skipping issue around DST ending

## 0.6.13

* Fix by Ben Fyvie for daily rule crossing over a year boundary
* Additional accessor methods on validations and rules for easy use in microformats (thanks @jamesarosen)
* Fix for changing start date affecting schedules without reloading
* Fix for typo in `active_support_occurs_between`? causing load issues with ActiveSupport (thanks @carlthuringer)

## 0.6.12

* Be able to set the `start_date` and duration after creating a schedule

## 0.6.11

* Added the ability to add and remove rdates, rrules, exdates, and exrules from a schedule

## 0.6.10

* UNTIL date now serialized with time information

## 0.6.9

* Added support for `Schedule#occurs_between?`

## 0.6.5

* Added a `:start_date_override` option to `from_hash` / `from_yaml` (@sakrafd)

## 0.6.4

* Fixed bug where `next_occurrence` wouldn't actually grab the correct next occurrence with schedules that had more than one recurrence rule and/or a recurrence rule and a recurrence date
* Added `next_occurrences` function to schedule, allowing you to get the next _N_ occurrences after a given date

## 0.6.3

* Change how `active_support_occurs_on` works
* Fixed bug where `next_occurrence` wouldn't work if no `end_date` was set

## 0.6.2

* Patch release for `to_yaml` performance issue

## 0.6.1

* Lessen the amount of info we store in yaml on the time zone

## 0.6.0

* Changed how time serialization is done to preserve TimeWithZone when appropriate. (#8)
* Backward compatibility is intact, but bumping the minor version for the YAML format change.
* Fixed next occurrence to work on never-ending schedules (#11)
