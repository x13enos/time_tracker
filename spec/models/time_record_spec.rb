require 'rails_helper'

RSpec.describe TimeRecord, type: :model do

  it { should belong_to(:user) }
  it { should belong_to(:project) }

  describe '.active' do
    let!(:inactive_time_record) { create(:time_record, time_start: nil) }
    let!(:active_time_record) { create(:time_record, time_start: Time.now) }

    it "should return only active time_records" do
      expect(TimeRecord.active).to eq([active_time_record])
    end
  end

  describe '#active?' do
    it "should return true for task with time_start" do
      time_record = create(:time_record, time_start: Time.now)
      expect(time_record.active?).to be_truthy
    end

    it "should return false for task without time_start" do
      time_record = create(:time_record, time_start: nil)
      expect(time_record.active?).to be_falsey
    end
  end

  describe '#stop' do
    it "should set nil for time_start to stopped time record" do
      time_record = create(:time_record, spent_time: 0.5, time_start: Time.now)
      time_record.stop
      expect(time_record.time_start).to be_nil
    end

    it "should set spent time to stopped time record" do
      freeze_time do
        time_record = create(:time_record, spent_time: 0.5, time_start: Time.now - 60.minutes)
        time_record.stop
        expect(time_record.spent_time).to eq(1.5)
      end
    end
  end

end
