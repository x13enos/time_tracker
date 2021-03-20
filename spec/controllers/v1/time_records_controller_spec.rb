require 'rails_helper'

RSpec.describe V1::TimeRecordsController, type: :controller do

  describe "GET #index" do

    context 'user has problem with authorisation' do
      it 'should clean remember me token in case of expired token' do
        travel_to Time.zone.local(2019, 10, 29)
        user = create(:user)
        cookies[:token] = TokenCryptService.encode(user.email, nil)
        cookies[:remember_me] = true
        travel_back
        get :index, params: { assigned_date: "29-10-2019", format: :json }

        expect(cookies[:remember_me]).to be_nil
      end

      it 'should not update token if remember_me cookie was set' do
        travel_to Time.now - 10.days
        user = create(:user)
        token = TokenCryptService.encode(user.email, 30.days)
        cookies[:token] = token
        cookies[:remember_me] = true
        travel_back
        get :index, params: { assigned_date: "29-10-2019", format: :json }

        expect(cookies[:token]).to eq(token)
      end
    end

    context "user is authorised" do
      login_user(:staff)

      it "should set the right timezone for request" do
        expect(Time).to receive(:use_zone).with("Europe/Kiev")
        get :index, params: { assigned_date: "29-10-2019", current_timezone: "Europe/Kiev", format: :json }
      end

      it "should return weekly user's time records in the right order" do

        travel_to Time.zone.local(2019, 10, 29)
        time_start = Time.now - 1.hour

        project = create(:project, workspace: @current_user.active_workspace)
        time_record = create(:time_record, user: @current_user, time_start: time_start, assigned_date: Date.today, project: project)
        time_record_2 = create(:time_record, user: @current_user, created_at: Time.now + 1.hour, assigned_date: Date.today.beginning_of_week, project: project)
        time_record_3 = create(:time_record, assigned_date: Date.today + 1.week, project: project)

        get :index, params: { assigned_date: "29-10-2019", format: :json }
        expect(response.body).to eql({
          "time_records" => [
            {
              "id" => time_record.id,
              "description" => time_record.description,
              "project_id" => time_record.project_id,
              "tag_ids" => time_record.tag_ids,
              "assigned_date" => time_record.assigned_date.strftime("%d/%m/%Y"),
              "time_start" => time_record.time_start_as_epoch,
              "spent_time" => time_record.spent_time + 1.0
            },
            {
              "id" => time_record_2.id,
              "description" => time_record_2.description,
              "project_id" => time_record_2.project_id,
              "tag_ids" => time_record_2.tag_ids,
              "assigned_date" => time_record_2.assigned_date.strftime("%d/%m/%Y"),
              "time_start" => time_record_2.time_start_as_epoch,
              "spent_time" => time_record_2.spent_time
            }
          ]
        }.to_json)

        travel_back
      end
    end

  end

  describe "GET #active" do
    login_user(:staff)

    it "should return active time record for current user" do

      travel_to Time.zone.local(2019, 10, 29)

      project = create(:project, workspace: @current_user.active_workspace)
      time_record = create(:time_record, user: @current_user,  assigned_date: Date.today, project: project)
      time_record_2 = create(:time_record, user: @current_user, assigned_date: Date.today.beginning_of_week, project: project, time_start: Time.now - 1.hour)
      get :active, params: { format: :json }

      expect(response.body).to eql({
        "id" => time_record_2.id,
        "description" => time_record_2.description,
        "project_id" => time_record_2.project_id,
        "tag_ids" => time_record_2.tag_ids,
        "time_start" => time_record_2.time_start_as_epoch,
        "spent_time" => 1.0,
        "assigned_date" => time_record_2.assigned_date.strftime("%d/%m/%Y")
      }.to_json)

      travel_back
    end

    it "should nothing in case of active time record absence" do

      travel_to Time.zone.local(2019, 10, 29)

      project = create(:project, workspace: @current_user.active_workspace)
      time_record = create(:time_record, user: @current_user,  assigned_date: Date.today, project: project)
      time_record_2 = create(:time_record, user: @current_user, assigned_date: Date.today.beginning_of_week, project: project)
      get :active, params: { format: :json }

      expect(response.body).to be_empty

      travel_back
    end
  end

  describe "POST #create" do
    login_user(:staff)

    let!(:project) { create(:project) }

    context "params are valid" do
      let(:time_record_params) do
        {
          assigned_date: "28-10-2019",
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
          "tag_ids" => time_record.tag_ids,
          "time_start" => time_record.time_start_as_epoch,
          "spent_time" => time_record.spent_time,
          "assigned_date" => "28/10/2019"
        }.to_json)
      end

      it "should set start time if param with this key was passed info" do
        travel_to Time.zone.local(2019, 10, 28)

        post :create, params: time_record_params.merge({ start_task: true, current_timezone: "Europe/Kiev" })
        expect(TimeRecord.last.time_start).to be_present

        travel_back
      end
    end

    context "params are invalid" do
      let(:time_record_params) do
        {
          assigned_date: "29-10-2019",
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
        expect(response.body).to eq({ errors: { description: ["can't be blank"]} }.to_json)
      end
    end
  end

  describe "PUT #update" do
    login_user(:staff)
    let(:project) { create(:project, workspace: @current_user.active_workspace )}
    let(:time_record) { create(:time_record, user: @current_user, project: project) }

    context "params are valid" do
      let(:time_record_params) do
        {
          assigned_date: "28-10-2019",
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
          "tag_ids" => time_record.tag_ids,
          "time_start" => time_record.time_start_as_epoch,
          "spent_time" => time_record.spent_time,
          "assigned_date" => time_record.assigned_date.strftime("%d/%m/%Y")
        }.to_json)
      end

      it "should set start time if param with this key was passed info" do
        travel_to Time.zone.local(2019, 10, 28)

        put :update, params: { id: time_record.id, start_task: true, format: :json, current_timezone: "Europe/Kiev" }
        expect(TimeRecord.last.time_start).to be_present

        travel_back
      end

      it "should set start time as nil if spicific param for stopping issue was passed" do
        travel_to Time.zone.local(2019, 10, 28)

        put :update, params: { id: time_record.id, start_task: false, format: :json }
        expect(time_record.reload.time_start).to be_nil

        travel_back
      end

      it "shouldn't change start time if param for stopping issue was not passed" do
        travel_to Time.zone.local(2019, 10, 28)

        expect { put :update, params: { id: time_record.id,  format: :json } }.to_not change { time_record.time_start }

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
        expect(response.body).to eq({ errors: { description: ["can't be blank"] } }.to_json)
      end
    end
  end

  describe "DELETE #destroy" do
    login_user(:staff)
    let!(:project) { create(:project, workspace: @current_user.active_workspace )}
    let!(:time_record) { create(:time_record, user: @current_user, project: project) }

    it "should delete time record" do
      expect{ delete :destroy, params: { id: time_record.id, format: :json } }.to change{ TimeRecord.count }.from(1).to(0)
    end

    it "should return time record's info" do
      delete :destroy, params: { id: time_record.id, format: :json }
      expect(response.body).to eql({
        "id" => time_record.id,
        "description" => time_record.description,
        "project_id" => time_record.project_id,
        "tag_ids" => time_record.tag_ids,
        "time_start" => time_record.time_start_as_epoch,
        "spent_time" => time_record.spent_time,
        "assigned_date" => time_record.assigned_date.strftime("%d/%m/%Y")
      }.to_json)
    end
  end
end
