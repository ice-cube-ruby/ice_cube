# Upgrading

## 0.12.0

Previous versions used `start_date` as a hash key. This version introduces a
deprecation by renaming to `start_time` for consistency: see 
[issue #102][issue-102]. The old name will continue to be recognized when
reading seralized schedules from previous versions, and we will default to
exporting serialized schedules with *both* names. You can disable this
duplication by setting `IceCube.compatibility = 12` after your downstream code
is updated to look for `start_time`. Watch for deprecation notices in your log.

[issue-102]: https://github.com/seejohnrun/ice_cube/issues/102
