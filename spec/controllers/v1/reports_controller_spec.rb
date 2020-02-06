require 'rails_helper'

RSpec.describe V1::ReportsController, type: :controller do

  def create_time_records(user)
    travel_to Time.zone.local(2019, 10, 29)

    @time_record = create(:time_record, user: @current_user, assigned_date: Time.zone.today, spent_time: 0.45)
    @time_record_2 = create(:time_record, user: @current_user, created_at: Time.zone.now - 2.hour, assigned_date: Time.zone.today, spent_time: 1.44)
    @time_record_3 = create(:time_record, user: create(:user), assigned_date: Time.zone.today)
    @time_record_4 = create(:time_record, user: @current_user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today - 10.days, spent_time: 3.5)
    @time_record_5 = create(:time_record, user: @current_user, assigned_date: Time.zone.today - 25.days)

    travel_back
  end

  describe "GET #report" do
    context "staff user" do
      login_staff

      before { create_time_records(@current_user) }

      it "should return only specified user's time records by the period" do
        get :index, params: { from_date: 1571153533, to_date: 1572372039, user_id: @current_user.id, format: :json }
        expect(response.body).to eql({
          "time_records" => [
            {
              "id" => @time_record.id,
              "description" => @time_record.description,
              "project_id" => @time_record.project_id,
              "project_name" => @time_record.project.name,
              "user_name" => @time_record.user.name,
              "assigned_date" => @time_record.assigned_date,
              "time_start" => @time_record.time_start_as_epoch,
              "spent_time" => @time_record.spent_time
            },
            {
              "id" => @time_record_4.id,
              "description" => @time_record_4.description,
              "project_id" => @time_record_4.project_id,
              "project_name" => @time_record_4.project.name,
              "user_name" => @time_record_4.user.name,
              "assigned_date" => @time_record_4.assigned_date,
              "time_start" => @time_record_4.time_start_as_epoch,
              "spent_time" => @time_record_4.spent_time
            },
            {
              "id" => @time_record_2.id,
              "description" => @time_record_2.description,
              "project_id" => @time_record_2.project_id,
              "project_name" => @time_record_2.project.name,
              "user_name" => @time_record_2.user.name,
              "assigned_date" => @time_record_2.assigned_date,
              "time_start" => @time_record_2.time_start_as_epoch,
              "spent_time" => @time_record_2.spent_time
            }
          ],
          "total_spent_time" => 5.39
        }.to_json)
      end
    end

    context "admin user" do
      login_admin

      before { create_time_records(@current_user) }

      it "should return empty array if passed used id is wrong" do
        get :index, params: { from_date: 1571153533, to_date: 1572372039, user_id: 84985839, format: :json }
        expect(response.body).to eql({
          "time_records" => [],
          "total_spent_time" => 0.0
        }.to_json)
      end
    end

    context "when pdf flag was passed in params" do
      login_staff

      before { create_time_records(@current_user) }

      it "should generate build report instance" do
        converted_dates = {
          from: 1571153533.convert_to_date_time,
          to: 1572372039.convert_to_date_time
        }
        allow(@current_user).to receive_message_chain(:time_records, :joins, :joins, :where, :order) { [@time_record] }
        expect(ReportGenerator).to receive(:new).with([@time_record], converted_dates, @current_user) { double({ perform: true }) }
        get :index, params: { from_date: "1571153533", to_date: "1572372039", pdf: true, user_id: @current_user.id, format: :json }
      end

      it "should return link" do
        allow(ReportGenerator).to receive(:new) { double({ perform: "link_to_file" }) }
        get :index, params: { from_date: "1571153533", to_date: "1572372039", pdf: true, user_id: @current_user.id, format: :json }
        expect(response.body).to eq({ link: "link_to_file" }.to_json)
      end
    end
  end
end
