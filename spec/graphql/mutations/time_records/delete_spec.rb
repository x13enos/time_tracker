require "rails_helper"

RSpec.describe Mutations::TimeRecords::Delete do

  let!(:current_user) { create(:user, :admin) }
  let!(:context) { { current_user: current_user } }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:query_string) do
    %|mutation{
        deleteTimeRecord(
          timeRecordId: "#{time_record_id}"
        ){
        timeRecord{
          id
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:time_record) { create(:time_record, id: 101, user: current_user) }
      let!(:time_record_id) { "VGltZVJlY29yZC0xMDE=" }

      it "should delete time record" do
        expect { result }.to change { TimeRecord.count }.from(1).to(0)
      end

      it "should return time record's data" do
        expect(result['data']['deleteTimeRecord']['timeRecord']['id']).to eq(time_record_id)
      end
    end

    context "when passed id is wrong" do
      let!(:time_record_id) { "UHJvamVjdC0y" }

      it "should return error if time record with passed id wasn't find" do
        expect(result["errors"][0]["message"]).to eq("Passed id is wrong or record didn't find")
      end
    end
  end
end
