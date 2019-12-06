require "rails_helper"

RSpec.describe Queries::TimeRecords::Daily do

  let!(:current_user) { create(:user, :admin) }

  let!(:time) { Time.now }
  let!(:epoch_time) { time.utc.iso8601.to_time.to_i }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|query{
      dailyTimeRecords(
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
        travel_to Time.zone.local(2019, 10, 29)
        time_start = Time.zone.now - 1.hour

        time_record = create(:time_record, user: current_user, time_start: time_start, assigned_date: Time.zone.today)
        time_record_2 = create(:time_record, user: current_user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today)
        time_record_3 = create(:time_record, assigned_date: Time.zone.today)

        expect(result['data']['dailyTimeRecords']).to eq([
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
            "spentTime" => time_record.spent_time + 1.0,
            "timeStart" => time_start.utc.iso8601.to_time.to_i,
            "project" => {
              "id" => encode_id(time_record.project)
            }
          }
        ])

        travel_back
      end

      it "should return none of time records if all of them were created in other days" do
        travel_to Time.zone.local(2019, 10, 30)

        time_record = create(:time_record, user: current_user, time_start: time, assigned_date: Time.zone.today)
        time_record_2 = create(:time_record, user: current_user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today)
        time_record_3 = create(:time_record, assigned_date: Time.zone.today)

        expect(result['data']['dailyTimeRecords']).to be_empty

        travel_back
      end
    end
  end
end
