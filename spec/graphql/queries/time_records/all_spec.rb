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
        date: 1572372039
      ){
        id,
        description,
        spentTime,
        timeStart,
        project{
          id
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do

      context "user wasn't passed" do
        let!(:context) { { current_user: nil } }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq(I18n.t('graphql.errors.not_authorized'))
        end

        it "should return error code" do
          expect(result["errors"][0]["extensions"]["code"]).to eq("401")
        end
      end

      it "should return time only current user's time recors in the right order" do
        travel_to Time.local(2019, 10, 29)

        time_record = create(:time_record, user: current_user, time_start: time, assigned_date: Date.today)
        time_record_2 = create(:time_record, user: current_user, created_at: Time.now - 1.hour, assigned_date: Date.today)
        time_record_3 = create(:time_record, assigned_date: Date.today)

        expect(result['data']['allTimeRecords']).to eq([
          {
            "id" => encode_id(time_record_2),
            "description" => time_record_2.description,
            "spentTime" => time_record_2.spent_time,
            "timeStart" => time_record_2.time_start,
            "project" => {
              "id" => encode_id(time_record_2.project)
            }
          },

          {
            "id" => encode_id(time_record),
            "description" => time_record.description,
            "spentTime" => time_record.spent_time,
            "timeStart" => epoch_time,
            "project" => {
              "id" => encode_id(time_record.project)
            }
          }
        ])

        travel_back
      end

      it "should return none of time records if all of them were created in other days" do
        travel_to Time.local(2019, 10, 30)

        time_record = create(:time_record, user: current_user, time_start: time, assigned_date: Date.today)
        time_record_2 = create(:time_record, user: current_user, created_at: Time.now - 1.hour, assigned_date: Date.today)
        time_record_3 = create(:time_record, assigned_date: Date.today)

        expect(result['data']['allTimeRecords']).to be_empty

        travel_back
      end
    end
  end
end
