require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe TimeUtil do
    describe :beginning_of_date do
      let(:utc_time) { Time.utc(2014, 7, 8, 12, 34, 56) }
      let(:dst_time) { Time.local(2014, 7, 8, 12, 34, 56) }
      let(:std_time) { Time.local(2014, 1, 1, 12, 34, 56) }

      it "returns 00:00:00 crossing into DST" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, std_time)
        dst_diff = dst_time.utc_offset - std_time.utc_offset
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset - std_time.utc_offset).to eq dst_diff
      end

      it "returns 00:00:00 crossing out of DST" do
        time = TimeUtil.beginning_of_date(std_time.to_date, dst_time)
        dst_diff = std_time.utc_offset - dst_time.utc_offset
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset - dst_time.utc_offset).to eq dst_diff
      end

      it "returns 00:00:00 from UTC for local time" do
        time = TimeUtil.beginning_of_date(utc_time.to_date, dst_time)
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset).to eq dst_time.utc_offset
      end

      it "returns 00:00:00 from local time for UTC" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, utc_time)
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc?).to eq true
      end

      it "returns 00:00:00 from local time for nonlocal time" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, std_time.getlocal(7200))

        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset).to eq 7200
      end
    end

    describe :wday_to_sym do
      [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |sym, i|
        it "converts #{i} to weekday symbol :#{sym}" do
          expect(TimeUtil.wday_to_sym(i)).to eq(sym)
        end

        it "returns :#{sym} when passed :#{sym}" do
          expect(TimeUtil.wday_to_sym(sym)).to eq(sym)
        end
      end

      it "raises an error for bad input" do
        expect { TimeUtil.wday_to_sym(:anyday) }.to raise_error(ArgumentError)
        expect { TimeUtil.wday_to_sym(8) }.to raise_error(ArgumentError)
        expect { TimeUtil.wday_to_sym(-1) }.to raise_error(ArgumentError)
      end
    end

    describe :sym_to_wday do
      [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |sym, i|
        it "converts :#{sym} to integer #{i}" do
          expect(TimeUtil.sym_to_wday(sym)).to eq(i)
        end

        it "returns #{i} when passed #{i}" do
          expect(TimeUtil.sym_to_wday(i)).to eq(i)
        end
      end

      it "raises an error for bad input" do
        expect { TimeUtil.sym_to_wday(:anyday) }.to raise_error(ArgumentError)
        expect { TimeUtil.sym_to_wday(-1) }.to raise_error(ArgumentError)
        expect { TimeUtil.sym_to_wday(8) }.to raise_error(ArgumentError)
      end
    end

    describe :sym_to_month do
      it "converts month symbols to 1..12 month numbers" do
        expect(TimeUtil.sym_to_month(:january)).to eq(1)
      end

      it "returns month numbers as is" do
        expect(TimeUtil.sym_to_month(12)).to eq(12)
      end

      it "raises an error for bad input" do
        expect { TimeUtil.sym_to_month(13) }.to raise_error(ArgumentError)
        expect { TimeUtil.sym_to_month(:neveruary) }.to raise_error(ArgumentError)
      end
    end

    describe :deserialize_time do
      it "supports ISO8601 time strings" do
        expect(TimeUtil.deserialize_time("2014-04-04T18:30:00+08:00")).to eq(Time.utc(2014, 4, 4, 10, 30, 0))
      end
    end

    describe :match_zone do
      let(:date) { Date.new(2014, 1, 1) }

      WORLD_TIME_ZONES.each do |zone|
        context "in #{zone}", system_time_zone: zone do
          let(:utc_time) { Time.utc(2014, 1, 1, 0, 0, 1) }
          let(:local_time) { Time.local(2014, 1, 1, 0, 0, 1) }

          it "converts Date to beginning of date of local reference time" do
            expect(TimeUtil.match_zone(date, local_time)).to eq local_time - 1
          end

          it "converts Date to beginning of date of UTC reference time" do
            expect(TimeUtil.match_zone(date, utc_time)).to eq utc_time - 1
          end
        end
      end

      context "in UTC" do
        let(:utc_time) { Time.utc(2014, 1, 1, 0, 0, 1) }

        it "converts Date to beginning of date of reference time" do
          expect(TimeUtil.match_zone(date, utc_time)).to eq utc_time - 1
        end
      end
    end
  end
end
