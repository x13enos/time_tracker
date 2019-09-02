require "rails_helper"

RSpec.describe Mutations::TimeRecords::Create do

  let!(:current_user) { create(:user) }
  let!(:project) { create(:project) }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:start_task) { false }

  let(:query_string) do
    %|mutation {
      createTimeRecord(
        startTask: #{start_task},
        data: {
          description: "#{ description }",
          spentTime: 0.75,
          projectId: #{ project.id }
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
      let!(:description) { 'New task' }

      context "user isn't authorized" do
        let!(:context) { { current_user: nil } }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq("You are not authorized to perform this action.")
        end
      end

      context "user was authorized" do
        let!(:context) { { current_user: current_user } }
        let(:start_task) { true }

        it "should create new time record" do
          expect { result }.to change{ TimeRecord.count }.from(0).to(1)
        end

        it "should return project's data" do
          expect(result['data']['createTimeRecord']['timeRecord']['description']).to eq('New task')
        end

        it "should set current time as started" do
          freeze_time do
            result
            expect(TimeRecord.last.time_start).to eq(Time.now)
          end
        end

        context "when passed start_time flag is false" do
          let(:start_task) { false }

          it "shouldn't set time_start" do
            result
            expect(TimeRecord.last.time_start).to be_nil
          end
        end
      end
    end

    context "when passed data is wrong" do
      let!(:description) { nil }
      let!(:context) { { current_user: current_user } }

      it "should return error if description wasn't passed" do
        expect(result['errors'][0]['message']).to_not be_empty
      end
    end
  end
end
