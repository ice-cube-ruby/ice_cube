require File.dirname(__FILE__) + '/spec_helper'

describe IceCube, 'to_ical' do

  it 'should return a proper ical representation' do
    rule = Rule.daily(2)
    rule.day(:monday, :tuesday)
    rule.day_of_year(100)
    rule.day_of_week(:monday => [1, -1], :wednesday => [2, -1])
    rule.day_of_month(31, -2)
  end
  
end
