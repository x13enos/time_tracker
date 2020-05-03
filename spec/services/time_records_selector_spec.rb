require "rails_helper"

RSpec.describe TimeRecordsSelector do
  def create_time_records(user)
    travel_to Time.zone.local(2019, 10, 29)

    project = create(:project, workspace: user.active_workspace)
    @time_record = create(:time_record, user: user, description: "TT-88: first", assigned_date: Date.today, spent_time: 0.45, project: project)
    @time_record_2 = create(:time_record, user: user, description: "TT-78: second", created_at: Time.now - 2.hour, assigned_date: Date.today, spent_time: 1.44, project: project)
    @time_record_3 = create(:time_record, user: create(:user), assigned_date: Time.zone.today, project: project)
    @time_record_4 = create(:time_record, user: user, description: "TT-88: third", created_at: Time.now - 1.hour, assigned_date: Date.today - 10.days, spent_time: 3.5, project: project)

    travel_back
  end

  let(:project) { create(:project, regexp_of_grouping: '\ATT-\d+:', workspace: user.active_workspace) }
  let(:user) { create(:user) }
  let(:params) {
    {
      from_date: "15-10-2019",
      to_date: "29-10-2019"
    }
  }

  before { create_time_records(user) }

  describe "perform" do
    context "grouped_time_records" do
      it "should return empty array if user wasn't passed" do
        result = TimeRecordsSelector.new(params, nil).perform
        expect(result[:grouped_time_records]).to be_empty
      end

      it "should return grouped time records if they assigned to project with regexp" do
        [@time_record, @time_record_2, @time_record_4].each { |t| t.update(project_id: project.id) }
        result = TimeRecordsSelector.new(params, user).perform
        expect(result[:grouped_time_records]).to eq([
          [@time_record, @time_record_4], [@time_record_2]
        ])
      end
    end

    it "shold return list of projects" do
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:projects]).to include(@time_record.project, @time_record_2.project, @time_record_4.project)
    end

    it "shold return converted timestamps" do
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:converted_dates]).to eq({
        from: "15-10-2019".to_date,
        to: "29-10-2019".to_date,
      })
    end

    it "shold return total spent time for selected time records" do
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:total_spent_time]).to eq(5.39)
    end
  end
end
