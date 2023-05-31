# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Indonesian translations. ([#505](https://github.com/seejohnrun/ice_cube/pull/505)) by [@achmiral](https://github.com/achmiral)
- Support for Ruby 3.2

### Changed
- Removed use of `delegate` method added in [66f1d797](https://github.com/ice-cube-ruby/ice_cube/commit/66f1d797092734563bfabd2132c024c7d087f683) , reverting to previous implementation. ([#522](https://github.com/ice-cube-ruby/ice_cube/pull/522))  by [@pacso](https://github.com/pacso)

### Fixed
- Fix for weekly interval results when requesting `occurrences_between` on a narrow range ([#487](https://github.com/seejohnrun/ice_cube/pull/487)) by [@jakebrady5](https://github.com/jakebrady5)
- When using a rule with hour_of_day validations, and asking for occurrences on the day that DST skips forward, valid occurrences would be missed. ([#464](https://github.com/seejohnrun/ice_cube/pull/464)) by [@jakebrady5](https://github.com/jakebrady5)
- Include `exrules` when exporting a schedule to YAML, JSON or a Hash. ([#519](https://github.com/ice-cube-ruby/ice_cube/pull/519)) by [@pacso](https://github.com/pacso)

## [0.16.4] - 2021-10-21
### Added
- Italian translations

## [0.16.3] - 2018-07-23
### Added
- Support for parsing RDATE from iCal format

## [0.16.2] - 2017-07-10
### Fixed
- Fix serialization of Date values (for `until`) ([#399](https://github.com/seejohnrun/ice_cube/pull/399))
- Fix double DST occurrences ([#398](https://github.com/seejohnrun/ice_cube/pull/398))
- Realign first wday for monday-based weekly rules ([#402](https://github.com/seejohnrun/ice_cube/pull/402))
- Fix weekly realignment for `spans: true` option ([#402](https://github.com/seejohnrun/ice_cube/pull/402))

## [0.16.1] - 2017-05-03
### Added
- Add pt-BR i18n locale ([#388](https://github.com/seejohnrun/ice_cube/pull/388))

### Fixed
- Misaligned first weekly occurrence ([#387](https://github.com/seejohnrun/ice_cube/pull/387))

## [0.16.0] - 2017-04-12
### Added
- Support for Ruby 2.4

### Changed
- Raise ArgumentError on empty values for remaining rules ([#373](https://github.com/seejohnrun/ice_cube/pull/373))

### Fixed
- Fix biweekly realign with spans option ([#377](https://github.com/seejohnrun/ice_cube/pull/377))
- Fix `day_of_year` with negative offsets ([#326](https://github.com/seejohnrun/ice_cube/pull/326))
- Fix weekly rule alignment with non-Sunday week start ([#383](https://github.com/seejohnrun/ice_cube/pull/383))

## [0.15.0] - 2017-01-27
### Added
- I18n translations for Russian, Swedish, German, and French

### Changed
- Support testing with different `RAILS_VERSION`
- Support "until" Date with local Time conversion ([#327](https://github.com/seejohnrun/ice_cube/pull/327))
- Validate rules (and raise ArgumentError) on empty `from_hash`

### Fixed
- Fix validations on `Rule.from_hash` with empty array ([#281](https://github.com/seejohnrun/ice_cube/pull/281))

## [0.14.0] - 2016-02-23
### Added
- Option to include prior occurrences with overlapping duration ([#302](https://github.com/seejohnrun/ice_cube/pull/302))

## [0.13.3] - 2016-01-30
### Changed
- Performance optimizations
- Default deprecation compatibility to track the current version

## [0.13.2] - 2015-12-09

No changes.

## [0.13.1] - 2015-12-07
### Added
- I18n support!
- Option to include prior occurrences with overlapping duration ([#154](https://github.com/seejohnrun/ice_cube/pull/154))

## [0.13.0] - 2015-05-26

NOTE: the commit for the _v0.13.0_ release tag incorrectly says _Release 0.13.1_

### Added
- Add `from_ical`! ([#258](https://github.com/seejohnrun/ice_cube/pull/258))

### Fixed
- Method arity for `ActiveSupport::TimeZone.to_s` ([#255](https://github.com/seejohnrun/ice_cube/pull/255))
- Fix whole-day skip with date inputs
- Missed times selected from gap week with weekly interval > 1 ([#241](https://github.com/seejohnrun/ice_cube/pull/241))
- Fix `occurs_on?` miss near midnight for DST ([#245](https://github.com/seejohnrun/ice_cube/pull/245))

## [0.12.1] - 2014-07-04
### Added
- Support for deserialization of times via Time.parse

### Changed
- Added interval validations
- Deprecation message improvements

### Fixed
- Coerce validation intervals to Fixnum
- Fix YAML serialization on blank values in ActiveRecord ([#231](https://github.com/seejohnrun/ice_cube/pull/231))
- Yearly interval should return self like others

## [0.12.0] - 2014-04-06

### Added
- Rename to `start_time` as a hash key (see UPGRADING) ([#102](https://github.com/seejohnrun/ice_cube/pull/102))
- Notify of deprecated usage ([#219](https://github.com/seejohnrun/ice_cube/pull/219))

### Fixed
- Skip double occurrences over DST ([#189](https://github.com/seejohnrun/ice_cube/pull/189))
- Avoid symbolizing hash keys from input
- Ensure time comparisons are done in schedule time zone ([#209](https://github.com/seejohnrun/ice_cube/pull/209))
- Occurrence#overnight? now works on the last day of the month ([#218](https://github.com/seejohnrun/ice_cube/pull/218))

## [0.11.3] - 2014-02-07
### Fixed
- Fix a StopIteration leak

## [0.11.2] - 2014-01-25
### Changed
- Use Enumerator for schedule occurrences

### Fixed
- Fix high CPU usage on minutely schedules

## [0.11.1] - 2013-10-28
### Changed
- Move deprecated into IceCube namespace
- Standardize the exceptions that we raise

### Fixed
- Fix ActiveSupport edge case restoring serialized TZ

## [0.11.0] - 2013-06-13
### Added
- `schedule.last(n)` method ([#117](https://github.com/seejohnrun/ice_cube/pull/117))
- `previous_occurrence` & `previous_occurrences` methods ([#170](https://github.com/seejohnrun/ice_cube/pull/170))

### Fixed
- Occurrence `to_s` accepts format to comply with Rails

## [0.10.1] - 2013-05-17
### Changed
- Accept arrays in multiparameter DSL methods ([#139](https://github.com/seejohnrun/ice_cube/pull/139))

### Fixed
- Match time zone from schedule when finding times ([#152](https://github.com/seejohnrun/ice_cube/pull/152))
- Reliably calculate distance to same day in next month ([#171](https://github.com/seejohnrun/ice_cube/pull/171))
- Updating interval on a rule shouldn't leave duplicate validations ([#158](https://github.com/seejohnrun/ice_cube/pull/158)) ([#157](https://github.com/seejohnrun/ice_cube/pull/157))
- Allow Occurrence to work transparently with Arel ([#168](https://github.com/seejohnrun/ice_cube/pull/168))
- Raise errors for invalid input ([#139](https://github.com/seejohnrun/ice_cube/pull/139))

## [0.10.0] - 2013-02-25
### Added
- Add support for `week_start` (@masquita) ([#75](https://github.com/seejohnrun/ice_cube/pull/75))
- Schedule occurrences have end times ([#119](https://github.com/seejohnrun/ice_cube/pull/119))

### Changed
- Add block initialization, new schedule yields itself ([#146](https://github.com/seejohnrun/ice_cube/pull/146))
- Warn on use of DateTime and convert to local Time ([#144](https://github.com/seejohnrun/ice_cube/pull/144))
- Start time counts as an implicit occurrence (no more empty schedule) ([#135](https://github.com/seejohnrun/ice_cube/pull/135))

### Fixed
- Fix monthly intervals to not skip short months ([#105](https://github.com/seejohnrun/ice_cube/pull/105))
- Fix `occurring_between?` for zero-length occurrences at start boundary ([#147](https://github.com/seejohnrun/ice_cube/pull/147))
- Bug fix for count limit across multiple rules ([#149](https://github.com/seejohnrun/ice_cube/pull/149))
- Fix occurrences in DST transition ([#150](https://github.com/seejohnrun/ice_cube/pull/150))

## [0.9.3] - 2013-01-03
### Added
- Duration is dependent upon `end_time` ([#120](https://github.com/seejohnrun/ice_cube/pull/120))

### Changed
- Duration defaults to 0

### Fixed
- Match the subseconds of `start_time` when finding occurrences ([#89](https://github.com/seejohnrun/ice_cube/pull/89))
- Avoid microseconds when comparing times ([#83](https://github.com/seejohnrun/ice_cube/pull/83))
- Handle DateTime's lack of subseconds

## [0.9.2] - 2012-12-08
### Added
- Allow passing Time, Date, or DateTime to all calls

## [0.9.1] - 2012-10-19
### Fixed
- A fix for removing `until` validations ([#106](https://github.com/seejohnrun/ice_cube/pull/106))
- A DST edge fix

## [0.9.0] - 2012-10-12
### Added
- Fix the effect on `end_time` on IceCube::Schedule ([#99](https://github.com/seejohnrun/ice_cube/pull/99))
- Allow deserialization of string structures easily ([#93](https://github.com/seejohnrun/ice_cube/pull/93))
- Added `occurring_between?` ([#88](https://github.com/seejohnrun/ice_cube/pull/88))

### Changed
- Remove `end_time` from `to_s` ([#99](https://github.com/seejohnrun/ice_cube/pull/99))

### Fixed
- Single recurrences now work properly with `conflict_with?` ([#71](https://github.com/seejohnrun/ice_cube/pull/71))
- Fix a bug with interval > 1 when using `occurrences_between` ([#92](https://github.com/seejohnrun/ice_cube/pull/92))
- Allow count, until removal by setting to nil ([#94](https://github.com/seejohnrun/ice_cube/pull/94))
- Ignore usecs when creating Time.now for `*_occurrences` ([#84](https://github.com/seejohnrun/ice_cube/pull/84))
- DST bug fix ([#98](https://github.com/seejohnrun/ice_cube/pull/98))

## [0.8.0]
### Added
- Support for WEEKST by [@devwout](https://github.com/devwout)

## [0.7.9]
### Added
- Added INTERVAL to `to_ical` for all interval validations

## [0.7.8]
### Fixed
- Various bug fixes

## [0.7.7]
### Added
- Added "Weekends" and "Weekdays" to day's `to_s`

## [0.7.6]
### Added
- Support for `terminating?` and `conflicts_with?`

## [0.7.5]
### Fixed
- Fix an issue with `occurrences_between` when using count ([#54](https://github.com/seejohnrun/ice_cube/pull/54))

## [0.7.4]
### Fixed
- NameError when serializing schedule with `end_time` by [@digx](https://github.com/digx)

## [0.7.3]
### Fixed
- Fix for time interval buckets (affects hour, minute, sec)

## [0.7.2]
### Fixed
- Fix for interval to/from YAML issue

## [0.7.1]
### Fixed
- Fix for comparing rules with nil

## [0.7.0]
### Added
- Support for `each_occurrence` which iterates as it builds forever

### Changed
- Large rewrite, fixing a few small bugs and including some large optimizations to the spidering algo

## [0.6.15]
### Added
- Deserialize `until_date` properly in `to_hash` and `to_yaml` by [@promisedlandt](https://github.com/promisedlandt)

## [0.6.14]
### Fixed
- Fixed a skipping issue around DST ending

## [0.6.13]
### Added
- Additional accessor methods on validations and rules for easy use in microformats (thanks @jamesarosen)

### Fixed
- Fix by Ben Fyvie for daily rule crossing over a year boundary
- Fix for changing start date affecting schedules without reloading
- Fix for typo in `active_support_occurs_between`? causing load issues with ActiveSupport (thanks @carlthuringer)

## [0.6.12]
### Added
- Be able to set the `start_date` and duration after creating a schedule

## [0.6.11]
### Added
- Added the ability to add and remove rdates, rrules, exdates, and exrules from a schedule

## [0.6.10]
### Added
- UNTIL date now serialized with time information

## [0.6.9]
### Added
- Added support for `Schedule#occurs_between?`

## [0.6.5]
### Added
- Added a `:start_date_override` option to `from_hash` / `from_yaml` (@sakrafd)

## [0.6.4]
### Added
- Added `next_occurrences` function to schedule, allowing you to get the next _N_ occurrences after a given date

### Fixed
- Fixed bug where `next_occurrence` wouldn't actually grab the correct next occurrence with schedules that had more than one recurrence rule and/or a recurrence rule and a recurrence date

## [0.6.3]
### Changed
- Change how `active_support_occurs_on` works

### Fixed
- Fixed bug where `next_occurrence` wouldn't work if no `end_date` was set

## [0.6.2]
### Changed
- Patch release for `to_yaml` performance issue

## [0.6.1]
### Changed
- Lessen the amount of info we store in yaml on the time zone

## [0.6.0]
### Changed
- Changed how time serialization is done to preserve TimeWithZone when appropriate. ([#8](https://github.com/seejohnrun/ice_cube/pull/8))
- Backward compatibility is intact, but bumping the minor version for the YAML format change.

### Fixed
- Fixed next occurrence to work on never-ending schedules ([#11](https://github.com/seejohnrun/ice_cube/pull/11))

[Unreleased]: https://github.com/seejohnrun/ice_cube/compare/v0.16.4...HEAD
[0.16.4]: https://github.com/seejohnrun/ice_cube/compare/v0.16.3...v0.16.4
[0.16.3]: https://github.com/seejohnrun/ice_cube/compare/v0.16.2...v0.16.3
[0.16.2]: https://github.com/seejohnrun/ice_cube/compare/v0.16.1...v0.16.2
[0.16.1]: https://github.com/seejohnrun/ice_cube/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/seejohnrun/ice_cube/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/seejohnrun/ice_cube/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/seejohnrun/ice_cube/compare/v0.13.3...v0.14.0
[0.13.3]: https://github.com/seejohnrun/ice_cube/compare/v0.13.2...v0.13.3
[0.13.2]: https://github.com/seejohnrun/ice_cube/compare/v0.13.1...v0.13.2
[0.13.1]: https://github.com/seejohnrun/ice_cube/compare/v0.13.0...v0.13.1
[0.13.0]: https://github.com/seejohnrun/ice_cube/compare/v0.12.1...v0.13.0
[0.12.1]: https://github.com/seejohnrun/ice_cube/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/seejohnrun/ice_cube/compare/v0.11.3...v0.12.0
[0.11.3]: https://github.com/seejohnrun/ice_cube/compare/v0.11.2...v0.11.3
[0.11.2]: https://github.com/seejohnrun/ice_cube/compare/v0.11.1...v0.11.2
[0.11.1]: https://github.com/seejohnrun/ice_cube/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/seejohnrun/ice_cube/compare/v0.10.1...v0.11.0
[0.10.1]: https://github.com/seejohnrun/ice_cube/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/seejohnrun/ice_cube/compare/v0.9.3...v0.10.0
[0.9.3]: https://github.com/seejohnrun/ice_cube/compare/v0.9.2...v0.9.3
[0.9.2]: https://github.com/seejohnrun/ice_cube/compare/v0.9.1...v0.9.2
[0.9.1]: https://github.com/seejohnrun/ice_cube/compare/v0.9.0...v0.9.1
[0.9.0]: https://github.com/seejohnrun/ice_cube/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/seejohnrun/ice_cube/compare/v0.7.9...v0.8.0
[0.7.9]: https://github.com/seejohnrun/ice_cube/compare/v0.7.8...v0.7.9
[0.7.8]: https://github.com/seejohnrun/ice_cube/compare/v0.7.7...v0.7.8
[0.7.7]: https://github.com/seejohnrun/ice_cube/compare/v0.7.6...v0.7.7
[0.7.6]: https://github.com/seejohnrun/ice_cube/compare/v0.7.5...v0.7.6
[0.7.5]: https://github.com/seejohnrun/ice_cube/compare/v0.7.4...v0.7.5
[0.7.4]: https://github.com/seejohnrun/ice_cube/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/seejohnrun/ice_cube/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/seejohnrun/ice_cube/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/seejohnrun/ice_cube/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/seejohnrun/ice_cube/compare/v0.6.15...v0.7.0
[0.6.15]: https://github.com/seejohnrun/ice_cube/compare/v0.6.14...v0.6.15
[0.6.14]: https://github.com/seejohnrun/ice_cube/compare/v0.6.13...v0.6.14
[0.6.13]: https://github.com/seejohnrun/ice_cube/compare/v0.6.12...v0.6.13
[0.6.12]: https://github.com/seejohnrun/ice_cube/compare/v0.6.11...v0.6.12
[0.6.11]: https://github.com/seejohnrun/ice_cube/compare/v0.6.10...v0.6.11
[0.6.10]: https://github.com/seejohnrun/ice_cube/compare/v0.6.9...v0.6.10
[0.6.9]: https://github.com/seejohnrun/ice_cube/compare/v0.6.8...v0.6.9
[0.6.5]: https://github.com/seejohnrun/ice_cube/compare/v0.6.4...v0.6.5
[0.6.4]: https://github.com/seejohnrun/ice_cube/compare/v0.6.3...v0.6.4
[0.6.3]: https://github.com/seejohnrun/ice_cube/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/seejohnrun/ice_cube/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/seejohnrun/ice_cube/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/seejohnrun/ice_cube/compare/v0.5.9...v0.6.0
