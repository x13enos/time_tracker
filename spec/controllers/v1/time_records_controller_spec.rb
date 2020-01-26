require 'rails_helper'

RSpec.describe V1::TimeRecordsController, type: :controller do
  login_staff

  describe "get #index" do
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
end
