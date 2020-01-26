require 'rails_helper'

RSpec.describe V1::TimeRecordsController, type: :controller do
  login_staff

  describe "GET #index" do
    it "should return only daily user's time records in the right order" do
      travel_to Time.zone.local(2019, 10, 29)
      time_start = Time.zone.now - 1.hour
      epoch_time = 1572372039

      time_record = create(:time_record, user: @current_user, time_start: time_start, assigned_date: Time.zone.today)
      time_record_2 = create(:time_record, user: @current_user, created_at: Time.zone.now + 1.hour, assigned_date: Time.zone.today)
      time_record_3 = create(:time_record, assigned_date: Time.zone.today)

      get :index, params: { assigned_date: epoch_time, format: :json }
      expect(response.body).to eql({
        "time_records" => [
          {
            "id" => time_record_2.id,
            "description" => time_record_2.description,
            "project_id" => time_record_2.project_id,
            "time_start" => time_record_2.time_start_as_epoch,
            "spent_time" => time_record_2.spent_time
          },
          {
            "id" => time_record.id,
            "description" => time_record.description,
            "project_id" => time_record.project_id,
            "time_start" => time_record.time_start_as_epoch,
            "spent_time" => time_record.spent_time + 1.0
          }
      ]}.to_json)

      travel_back
    end

    context "when time period was passed" do
      before do
        travel_to Time.zone.local(2019, 10, 29)

        @time_record = create(:time_record, user: @current_user, assigned_date: Time.zone.today, spent_time: 0.45)
        @time_record_2 = create(:time_record, user: @current_user, created_at: Time.zone.now - 2.hour, assigned_date: Time.zone.today, spent_time: 1.44)
        @time_record_3 = create(:time_record, user: create(:user), assigned_date: Time.zone.today)
        @time_record_4 = create(:time_record, user: @current_user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today - 10.days, spent_time: 3.5)
        @time_record_5 = create(:time_record, user: @current_user, assigned_date: Time.zone.today - 25.days)

        travel_back
      end

      it "should return only specified user's time records by the period" do
        get :index, params: { from_date: "1571153533", to_date: "1572372039", format: :json }
        expect(response.body).to eql({
          "time_records" => [
            {
              "id" => @time_record.id,
              "description" => @time_record.description,
              "project_id" => @time_record.project_id,
              "time_start" => @time_record.time_start_as_epoch,
              "spent_time" => @time_record.spent_time
            },
            {
              "id" => @time_record_4.id,
              "description" => @time_record_4.description,
              "project_id" => @time_record_4.project_id,
              "time_start" => @time_record_4.time_start_as_epoch,
              "spent_time" => @time_record_4.spent_time
            },
            {
              "id" => @time_record_2.id,
              "description" => @time_record_2.description,
              "project_id" => @time_record_2.project_id,
              "time_start" => @time_record_2.time_start_as_epoch,
              "spent_time" => @time_record_2.spent_time
            }
          ],
          "total_spent_time" => 5.39
        }.to_json)
      end
    end
  end

  describe "POST #create" do
    let(:epoch_time) { 1572372039 }
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
          "spent_time" => time_record.spent_time
        }.to_json)
      end

      it "should set start time if param with this key was passed info" do
        travel_to Time.zone.local(2019, 10, 29)

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
        expect(response.body).to eq({ errors: ["Description can't be blank"] }.to_json)
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
          "spent_time" => time_record.spent_time
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
        expect(response.body).to eq({ errors: ["Description can't be blank"] }.to_json)
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
        "spent_time" => time_record.spent_time
      }.to_json)
    end
  end
end
