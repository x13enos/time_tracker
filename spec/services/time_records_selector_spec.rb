require "rails_helper"

RSpec.describe TimeRecordsSelector do
  def create_time_records(user)
    travel_to Time.zone.local(2019, 10, 29)
    workspace = user.active_workspace
    @time_record = create(:time_record, user: user, description: "TT-88: first", assigned_date: Date.today, spent_time: 0.45, project: project, workspace: workspace )
    @time_record_2 = create(:time_record, user: user, description: "TT-78: second", created_at: Time.now - 2.hour, assigned_date: Date.today, spent_time: 2, project: project_2, workspace: workspace)
    @time_record_3 = create(:time_record, user: create(:user), assigned_date: Time.zone.today, project: project, workspace: workspace)
    @time_record_4 = create(:time_record, user: user, description: "TT-88: third", created_at: Time.now - 1.hour, assigned_date: Date.today - 10.days, spent_time: 3.5, project: project_3, workspace: workspace)
    @time_record_5 = create(:time_record, user: user, description: "TL-89: test-description", assigned_date: Date.today, spent_time: 0.5, project: project_2, workspace: workspace)
    @time_record_6 = create(:time_record, user: user, description: "TKL-199: test-description", assigned_date: Date.today, spent_time: 0.45, project: project_2, workspace: workspace)

    travel_back
  end

  let(:project) { create(:project, workspace: user.active_workspace) }
  let(:project_2) { create(:project, workspace: user.active_workspace, regexp_of_grouping: "") }
  let(:project_3) { create(:project, workspace: user.active_workspace) }
  let(:project_with_regexp) { create(:project, regexp_of_grouping: '\ATT-\d+:', workspace: user.active_workspace) }
  let(:user) { create(:user) }
  let(:workspace) { user.active_workspace }
  let(:params) {
    {
      from_date: "15-10-2019",
      to_date: "29-10-2019"
    }
  }

  describe "perform" do

    context "grouped_time_records" do
      it "should return empty array if user wasn't passed" do
        create_time_records(user)
        result = TimeRecordsSelector.new(params, nil).perform
        expect(result[:grouped_time_records]).to be_empty
      end

      it "should return grouped time records if they assigned to project with regexp" do
        create_time_records(user)
        [@time_record, @time_record_2, @time_record_4].each { |t| t.update(project_id: project_with_regexp.id) }
        result = TimeRecordsSelector.new(params, user).perform
        expect(result[:grouped_time_records].size).to eq(4)
        expect(result[:grouped_time_records]).to include([@time_record_5], [@time_record_6], [@time_record, @time_record_4], [@time_record_2])
      end

      it "shouldn't raise error in case of having tasks w/o project" do
        create_time_records(user)

        travel_to Time.zone.local(2019, 10, 29)
        workspace = user.active_workspace
        @time_record = create(:time_record, user: user, description: "TT-88: first", assigned_date: Date.today, spent_time: 0.45, project: nil, workspace: workspace)
        travel_back

        expect { TimeRecordsSelector.new(params, user).perform }.not_to raise_error
      end
    end

    it "should return list of projects" do
      create_time_records(user)
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:projects]).to include(@time_record.project, @time_record_2.project, @time_record_4.project)
    end

    it "should return converted timestamps" do
      create_time_records(user)
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:converted_dates]).to eq({
        from: "15-10-2019".to_date,
        to: "29-10-2019".to_date,
      })
    end

    it "shold return total spent time for selected time records" do
      create_time_records(user)
      result = TimeRecordsSelector.new(params, user).perform
      expect(result[:total_spent_time]).to eq(6.9)
    end

    it "should return time records in the right order" do
      travel_to Time.zone.local(2019, 10, 29)
      @time_record = create(:time_record, user: user, created_at: Time.now - 1.hour, assigned_date: Date.today, workspace: workspace)
      @time_record_1 = create(:time_record, user: user, assigned_date: Date.today, workspace: workspace)
      travel_back

      result = TimeRecordsSelector.new(params, user).perform
      time_record_ids = result[:grouped_time_records].flatten.map(&:id)
      expect(time_record_ids).to eql([@time_record_1.id, @time_record.id])
    end

    it "should return time records which were filtered by tags" do
      travel_to Time.zone.local(2019, 10, 29)
      tag = create(:tag)
      tag_1 = create(:tag)
      tag_2 = create(:tag)
      time_record = create(:time_record, user: user, created_at: Time.now - 1.hour, assigned_date: Date.today, workspace: workspace)
      time_record_1 = create(:time_record, user: user, assigned_date: Date.today, workspace: workspace)
      time_record_2 = create(:time_record, user: user, assigned_date: Date.today, workspace: workspace)
      travel_back

      tag.time_records << [time_record, time_record_1]
      tag_1.time_records << [time_record_1]
      tag_2.time_records << [time_record_2]

      params.merge!(tags_ids: [tag.id, tag_1.id])
      result = TimeRecordsSelector.new(params, user).perform
      time_record_ids = result[:grouped_time_records].flatten.map(&:id)
      expect(time_record_ids).to eql([time_record_1.id, time_record.id])
    end

    it "should use passed workspace id for selecting time records" do
      travel_to Time.zone.local(2019, 10, 29)
      another_workspace = create(:workspace)

      @time_record = create(:time_record, user: user, assigned_date: Date.today, workspace: workspace)
      @time_record_1 = create(:time_record, user: user, assigned_date: Date.today, workspace: workspace)
      @time_record_2 = create(:time_record, user: user, assigned_date: Date.today, workspace: another_workspace)

      travel_back

      params[:workspace_id] = another_workspace.id
      result = TimeRecordsSelector.new(params, user).perform
      time_record_ids = result[:grouped_time_records].flatten.map(&:id)
      expect(time_record_ids).to eql([@time_record_2.id])
    end
  end
end
