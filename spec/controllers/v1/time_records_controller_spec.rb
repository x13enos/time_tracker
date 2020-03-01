require 'rails_helper'

RSpec.describe V1::TimeRecordsController, type: :controller do
  login_staff

  describe "GET #index" do
    it "should return weekly user's time records in the right order" do
      travel_to Time.zone.local(2019, 10, 29)
      time_start = Time.zone.now - 1.hour
      epoch_time = 1572372039

      time_record = create(:time_record, user: @current_user, time_start: time_start, assigned_date: Time.zone.today)
      time_record_2 = create(:time_record, user: @current_user, created_at: Time.zone.now + 1.hour, assigned_date: Time.zone.today.beginning_of_week)
      time_record_3 = create(:time_record, assigned_date: Time.zone.today + 1.week)

      get :index, params: { assigned_date: epoch_time, format: :json }
      expect(response.body).to eql({
        "time_records" => [
          {
            "id" => time_record.id,
            "description" => time_record.description,
            "project_id" => time_record.project_id,
            "assigned_date" => time_record.assigned_date.to_epoch,
            "time_start" => time_record.time_start_as_epoch,
            "spent_time" => time_record.spent_time + 1.0
          },
          {
            "id" => time_record_2.id,
            "description" => time_record_2.description,
            "project_id" => time_record_2.project_id,
            "assigned_date" => time_record_2.assigned_date.to_epoch,
            "time_start" => time_record_2.time_start_as_epoch,
            "spent_time" => time_record_2.spent_time
          }
        ]
      }.to_json)

      travel_back
    end
  end

  describe "POST #create" do
    let(:epoch_time) { 1572300000 }
    let!(:project) { create(:project) }

    context "params are valid" do
      let(:time_record_params) do
        {
          assigned_date: epoch_time,
          description: "test",
          spent_time: "0.0",
          project_id: project.id,
          format: :json
        }
      end

      it "should create time record" do
        expect{ post :create, params: time_record_params }.to change{ TimeRecord.count }.from(0).to(1)
      end

      it "should return time record's info" do
        post :create, params: time_record_params
        time_record = TimeRecord.last
        expect(response.body).to eql({
          "id" => time_record.id,
          "description" => time_record.description,
          "project_id" => time_record.project_id,
          "time_start" => time_record.time_start_as_epoch,
          "spent_time" => time_record.spent_time,
          "assigned_date" => time_record.assigned_date.to_epoch_beginning_of_day
        }.to_json)
      end

      it "should set start time if param with this key was passed info" do
        travel_to Time.zone.local(2019, 10, 29)

        allow(@current_user).to receive(:timezone) { "Europe/Helsinki" }

        post :create, params: time_record_params.merge({ start_task: true })
        expect(TimeRecord.last.time_start).to be_present

        travel_back
      end
    end

    context "params are invalid" do
      let(:time_record_params) do
        {
          assigned_date: epoch_time,
          description: "",
          spent_time: "0.0",
          project_id: project.id,
          format: :json
        }
      end

      it "should not create time record" do
        expect{ post :create, params: time_record_params }.to_not change{ TimeRecord.count }
      end

      it "should return error message" do
        post :create, params: time_record_params
        expect(response.body).to eq({ error: "Description can't be blank" }.to_json)
      end
    end
  end

  describe "PUT #update" do
    let(:epoch_time) { 1572372039 }
    let(:time_record) { create(:time_record, user: @current_user) }

    context "params are valid" do
      let(:time_record_params) do
        {
          assigned_date: epoch_time,
          description: "test",
          spent_time: "0.0",
          project_id: project.id,
          format: :json
        }
      end

      it "should update time record" do
        put :update, params: { id: time_record.id, description: "test_2", format: :json }
        expect(time_record.reload.description).to eq("test_2")
      end

      it "should return time record's info" do
        put :update, params: { id: time_record.id, description: "test_2", format: :json }
        expect(response.body).to eql({
          "id" => time_record.id,
          "description" => time_record.reload.description,
          "project_id" => time_record.project_id,
          "time_start" => time_record.time_start_as_epoch,
          "spent_time" => time_record.spent_time,
          "assigned_date" => time_record.assigned_date.to_epoch_beginning_of_day
        }.to_json)
      end

      it "should set start time if param with this key was passed info" do
        travel_to Time.zone.local(2019, 10, 29)

        put :update, params: { id: time_record.id, start_task: true, format: :json }
        expect(TimeRecord.last.time_start).to be_present

        travel_back
      end
    end

    context "params are invalid" do
      let(:time_record_params) do
        {
          id: time_record.id,
          description: "",
          format: :json
        }
      end

      it "should not update time record" do
        expect{ put :update, params: time_record_params }.to_not change{ time_record.description }
      end

      it "should return error message" do
        put :update, params: time_record_params
        expect(response.body).to eq({ error: "Description can't be blank" }.to_json)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:time_record) { create(:time_record, user: @current_user) }

    it "should delete time record" do
      expect{ delete :destroy, params: { id: time_record.id, format: :json } }.to change{ TimeRecord.count }.from(1).to(0)
    end

    it "should return time record's info" do
      delete :destroy, params: { id: time_record.id, format: :json }
      expect(response.body).to eql({
        "id" => time_record.id,
        "description" => time_record.description,
        "project_id" => time_record.project_id,
        "time_start" => time_record.time_start_as_epoch,
        "spent_time" => time_record.spent_time,
        "assigned_date" => time_record.assigned_date.to_epoch
      }.to_json)
    end
  end
end
