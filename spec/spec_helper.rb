require File.dirname(__FILE__) + '/../lib/ice_cube'
require 'cover_me'

# https://github.com/markbates/cover_me/issues/50
at_exit do
  CoverMe.complete!
end

DAY = Time.utc(2010, 3, 1)
WEDNESDAY = Time.utc(2010, 6, 23, 5, 0, 0)
