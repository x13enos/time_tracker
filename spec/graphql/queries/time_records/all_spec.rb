require "rails_helper"

RSpec.describe Queries::TimeRecords::All do

  let!(:current_user) { create(:user, :admin) }
  let!(:time) { Time.now }
  let!(:epoch_time) { time.utc.iso8601.to_time.to_i }
  let!(:time_record) { create(:time_record, user: current_user, time_start: time) }
  let!(:time_record_2) { create(:time_record, user: current_user, created_at: Time.now - 1.hour) }
  let!(:time_record_3) { create(:time_record) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      allTimeRecords{
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
          expect(result["errors"][0]["message"]).to eq("User must be logged in")
        end
      end

      it "should return time only current user's time recors in the right order" do
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
      end
    end
  end
end
