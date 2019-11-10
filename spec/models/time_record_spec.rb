require 'rails_helper'

RSpec.describe TimeRecord, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:spent_time) }
    it { should validate_presence_of(:assigned_date) }

    it { should belong_to(:user) }
    it { should belong_to(:project) }

    context "active_task_launched_today" do
      it "should add error if user tries to launch task that wasn't assigned to today" do
        freeze_time do
          time_record = create(:time_record, assigned_date: Date.today - 1.days)

          time_record.update(time_start: Time.now)
          expect(time_record.errors[:time_start]).to_not be_empty
        end
      end

      it "should not add error if user tries to launch today's task" do
        freeze_time do
          time_record = create(:time_record, assigned_date: Date.today)

          time_record.update(time_start: Time.now)
          expect(time_record.errors[:time_start]).to be_empty
        end
      end

      it "should not add error if user tries to change data for not today's task" do
        freeze_time do
          time_record = create(:time_record, assigned_date: Date.today - 1.days)

          time_record.update(description: "text")
          expect(time_record.errors[:time_start]).to be_empty
        end
      end
    end
  end

  describe '.active' do
    let!(:inactive_time_record) { create(:time_record, time_start: nil) }
    let!(:active_time_record) { create(:time_record, time_start: Time.now) }

    it "should return only active time_records" do
      expect(TimeRecord.active).to eq([active_time_record])
    end
  end

  describe '.stop' do
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
