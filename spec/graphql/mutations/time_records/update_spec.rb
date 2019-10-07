require "rails_helper"

RSpec.describe Mutations::TimeRecords::Update do

  let!(:current_user) { create(:user) }
  let!(:time_record) { create(:time_record, user: current_user, id: 101) }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }

  let(:query_string) do
    %|mutation {
      updateTimeRecord(
        startTask: #{start_task},
        timeRecordId: "VGltZVJlY29yZC0xMDE",
        projectId: #{ encode_id(time_record.project) }
        data: {
          description: "#{ description }",
          spentTime: 0.75
        }
      ) {
        timeRecord {
          description,
          spentTime,
          timeStart
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let(:description) { 'updated task' }

      context "user isn't authorized" do
        let(:context) { { current_user: nil } }
        let(:start_task) { false }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      context "user was authorized" do
        let!(:context) { { current_user: current_user } }
        let(:start_task) { true }

        it "should update time record" do
          result
          expect(time_record.reload.description).to eq(description)
        end

        it "should return project's data" do
          expect(result['data']['updateTimeRecord']['timeRecord']['description']).to eq(description)
        end

        it "should set current time as started" do
          freeze_time do
            result
            expect(time_record.reload.time_start).to eq(Time.now)
          end
        end

        context "when passed start_time flag is false" do
          let(:start_task) { false }

          it "should drop time_start" do
            time_record.update(time_start: Time.now)
            result
            expect(time_record.reload.time_start).to be_nil
          end
        end
      end
    end

    context "when passed data is wrong" do
      let!(:description) { nil }
      let!(:context) { { current_user: current_user } }
      let(:start_task) { false }

      it "should return error if description wasn't passed" do
        expect(result['errors'][0]['message']).to_not be_empty
      end
    end
  end
end
