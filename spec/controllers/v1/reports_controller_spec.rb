require 'rails_helper'

RSpec.describe V1::ReportsController, type: :controller do

  describe "GET #report" do
    context "staff user" do
      login_user(:staff)

      it "should build service for selecting time records" do
        expect(TimeRecordsSelector).to receive(:new) { double(perform: {
          grouped_time_records: []
        }) }
        get :index, params: { from_date: "15-10-2019", to_date: "29-10-2019", user_id: @current_user.id, format: :json }
      end

      it "should launch service for selecting time records" do
        selector = double
        allow(TimeRecordsSelector).to receive(:new) { selector }
        expect(selector).to receive(:perform) { { grouped_time_records: [] } }
        get :index, params: { from_date: "15-10-2019", to_date: "29-10-2019", user_id: @current_user.id, format: :json }
      end
    end

    context "admin user" do
      login_user(:admin)

      it "should return empty array if passed used id is wrong" do
        get :index, params: { from_date: "15-10-2019", to_date: "29-10-2019", user_id: 84985839, format: :json }
        expect(response.body).to eql({
          "time_records" => [],
          "total_spent_time" => 0.0
        }.to_json)
      end
    end

    context "when pdf flag was passed in params" do
      login_user(:staff)

      it "should generate build report instance" do
        converted_dates = {
          from: "15-10-2019".to_date,
          to: "29-10-2019".to_date
        }
        allow(TimeRecordsSelector).to receive_message_chain(:new, :perform) { ['time_records'] }
        expect(ReportGenerator).to receive(:new).with(['time_records'], @current_user) { double({ link: "link_to_file" }) }
        get :index, params: { from_date: "15-10-2019", to_date: "29-10-2019", pdf: true, user_id: @current_user.id, format: :json }
      end

      it "should return link" do
        allow(TimeRecordsSelector).to receive_message_chain(:new, :perform) { ['time_records'] }
        allow(ReportGenerator).to receive(:new) { double({ link: "link_to_file" }) }
        get :index, params: { from_date: "15-10-2019", to_date: "29-10-2019", pdf: true, user_id: @current_user.id, format: :json }
        expect(response.body).to eq({ link: "link_to_file" }.to_json)
      end
    end
  end
end
