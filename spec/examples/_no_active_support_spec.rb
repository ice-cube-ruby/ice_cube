require File.dirname(__FILE__) + '/../spec_helper'

# This file is loaded and run alphabetically first in the suite, before
# ActiveSupport gets loaded by other specs.

module IceCube
  describe TimeUtil, :if_active_support_time => false do

    before do
      Time.any_instance.should_receive(:respond_to?).with(:time_zone)
          .at_least(1).times.and_return(false)
    end

    WORLD_TIME_ZONES.each do |zone|
      context "in #{zone}", :system_time_zone => zone do

        it 'should be able to calculate end of dates without active_support' do
          date        = Date.new(2011, 1, 1)
          end_of_date = Time.local(2011, 1, 1, 23, 59, 59)
          TimeUtil.end_of_date(date).to_s.should == end_of_date.to_s
        end

        it 'should be able to calculate beginning of dates without active_support' do
          date = Date.new(2011, 1, 1)
          res = [ TimeUtil.beginning_of_date(date), Time.local(2011, 1, 1, 0, 0, 0) ]
          res.all? { |r| r.class.name == 'Time' }
          res.map(&:to_s).uniq.size.should == 1
        end

      end
    end

  end
end
