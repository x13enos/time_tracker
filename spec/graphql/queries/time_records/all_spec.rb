require "rails_helper"

RSpec.describe Queries::TimeRecords::All do

  let!(:current_user) { create(:user, :admin) }

  let!(:time) { Time.now }
  let!(:epoch_time) { time.utc.iso8601.to_time.to_i }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      allTimeRecords(
        fromDate: 1571153533,
        toDate: 1572372039,
        userId: "#{ user_id }"
      ){
        totalSpentTime,
        edges{
          node{
            id
          }
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do

      context "user wasn't passed" do
        let!(:user_id) { encode_id(current_user) }
        let!(:context) { { current_user: nil } }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq(I18n.t('graphql.errors.not_authorized'))
        end

        it "should return error code" do
          expect(result["errors"][0]["extensions"]["code"]).to eq("401")
        end
      end

      context "specific user was passed" do
        let!(:user) { create(:user) }
        let!(:specific_user) { create(:user) }
        let!(:user_id) { encode_id(specific_user) }
        let!(:context) { { current_user: user } }

        before do
          travel_to Time.zone.local(2019, 10, 29)

          @time_record = create(:time_record, user: specific_user, assigned_date: Time.zone.today, spent_time: 0.45)
          @time_record_2 = create(:time_record, user: specific_user, created_at: Time.zone.now - 2.hour, assigned_date: Time.zone.today, spent_time: 1.44)
          @time_record_3 = create(:time_record, user: user, assigned_date: Time.zone.today)
          @time_record_4 = create(:time_record, user: specific_user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today - 10.days, spent_time: 3.5)
          @time_record_5 = create(:time_record, user: specific_user, assigned_date: Time.zone.today - 25.days)

          travel_back
        end

        it "should return total spent time" do
          expect(result['data']['allTimeRecords']["totalSpentTime"]).to eq(5.39)
        end

        it "should return only specified user's time records by the period" do
          expect(result["data"]["allTimeRecords"]["edges"]).to eq([
            { "node" => { "id" => encode_id(@time_record) } },
            { "node" => { "id" => encode_id(@time_record_4) } },
            { "node" => { "id" => encode_id(@time_record_2) } }
          ])
        end
      end
    end
  end
end
