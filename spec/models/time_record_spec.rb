require 'rails_helper'

RSpec.describe TimeRecord, type: :model do

  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:project) }
    it { should have_one(:workspace).through(:project) }
    it { should have_and_belong_to_many(:tags) }
  end

  describe '.by_workspace' do
    it "should return list of time records selected by passed workspace" do
      workspace = create(:workspace)
      project1 = create(:project, workspace: workspace)
      project2 = create(:project)

      time_record1 = create(:time_record, project: project1)
      time_record2 = create(:time_record, project: project2)
      time_record3 = create(:time_record, project: project1)

      expect(TimeRecord.by_workspace(workspace.id)).to include(time_record1, time_record3)
      expect(TimeRecord.by_workspace(workspace.id).count).to eq(2)
    end
  end

  describe '.by_tags' do
    it "should return list of time records selected by passed tags ids" do
      tag1 = create(:tag)
      tag2 = create(:tag)

      time_record1 = create(:time_record, tags: [tag1])
      time_record2 = create(:time_record, tags: [tag2])
      time_record3 = create(:time_record, tags: [tag1, tag2])

      filtered_timre_records = TimeRecord.by_tags([tag1.id])
      expect(filtered_timre_records).to include(time_record1, time_record3)
      expect(filtered_timre_records.count).to eq(2)
    end
  end

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

  describe '#time_start_as_epoch' do
    it "should return time start as epoch if time record has that" do
      travel_to Time.zone.local(2019, 10, 29)

      time_record = create(:time_record, time_start: Time.now)
      expect(time_record.time_start_as_epoch).to eq(time_record.time_start.utc.iso8601.to_time.to_i)

      travel_back
    end

    it "should return nil if time record doesn't have time start" do
      time_record = create(:time_record, time_start: nil)
      expect(time_record.time_start_as_epoch).to be_nil
    end
  end

  describe '#calculated_spent_time' do
    it "should return real spent time if time record is active" do
      travel_to Time.zone.local(2019, 10, 29)

      time_record = create(:time_record, time_start: Time.now - 1.hours, spent_time: 0.5)
      expect(time_record.calculated_spent_time).to eq(1.5)

      travel_back
    end

    it "should return spent time from time record if it isn't active" do
      time_record = create(:time_record, time_start: nil, spent_time: 0.5)
      expect(time_record.calculated_spent_time).to eq(0.5)
    end
  end

  describe '#belongs_to_user?' do
    it "should return true if that belongs to the passed user" do
      user = create(:user)
      time_record = create(:time_record, user: user)

      expect(time_record.belongs_to_user?(user.id)).to be_truthy
    end

    it "should return false if that doesn't belong to the passed user" do
      user = create(:user)
      user_2 = create(:user)
      time_record = create(:time_record, user: user)

      expect(time_record.belongs_to_user?(user_2.id)).to be_falsey
    end
  end

  describe ".passed_time" do
    it "should return amount of passed seconds from the start" do
      travel_to Time.zone.local(2019, 10, 29)

      time_record = create(:time_record, time_start: Time.now - 1.hours)
      expect(time_record.passed_time).to eq(1)

      travel_back
    end
  end

  describe ".total_time" do
    it "should return sum of spent time and round that" do
      travel_to Time.zone.local(2019, 10, 29)

      user = create(:user)
      time_record = create(:time_record, user: user, spent_time: 2.35)
      time_record_2 = create(:time_record, user: user, spent_time: 2.859)
      time_record_3 = create(:time_record, user: user, spent_time: 0.5)

      expect(user.time_records.total_time).to eq(5.71)

      travel_back
    end

    it "should return sum of spent time + passed time from start for active task and round this as well" do
      travel_to Time.zone.local(2019, 10, 29)

      user = create(:user)
      time_record = create(:time_record, user: user, spent_time: 2.35)
      time_record_2 = create(:time_record, user: user, spent_time: 2.859)
      time_record_3 = create(:time_record, user: user, time_start: Time.now - 1.hours, spent_time: 0.5)

      expect(user.time_records.total_time).to eq(6.71)

      travel_back
    end
  end
end
