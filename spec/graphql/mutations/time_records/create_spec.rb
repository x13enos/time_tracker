require "rails_helper"

RSpec.describe Mutations::TimeRecords::Create do

  let!(:current_user) { create(:user) }
  let!(:project) { create(:project) }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
  let(:start_task) { false }
  let(:current_day) { Date.new(2019,10,28) }

  let(:query_string) do
    %|mutation {
      createTimeRecord(
        startTask: #{start_task},
        projectId: "#{ encode_id(project) }",
        data: {
          description: "#{ description }",
          spentTime: 0.75,
          assignedDate: 1572289845
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

      context "user wasn't passed" do
        let!(:context) { { current_user: nil } }

        it "should return error" do
          expect(result["errors"][0]["message"]).to eq(I18n.t('graphql.errors.not_authorized'))
        end

        it "should return error code" do
          expect(result["errors"][0]["extensions"]["code"]).to eq("401")
        end
      end

      context "user was authorized" do
        let!(:context) { { current_user: current_user } }
        let(:start_task) { true }

        it "should create new time record" do
          travel_to current_day do
            expect { result }.to change{ TimeRecord.count }.from(0).to(1)
          end
        end

        it "should return project's data" do
          travel_to current_day do
            expect(result['data']['createTimeRecord']['timeRecord']['description']).to eq('New task')
          end
        end

        it "should set current time as started" do
          travel_to current_day do
            result
            expect(TimeRecord.last.time_start).to eq(Time.now)
          end
        end

        it "should keep assigned date" do
          travel_to current_day do
            result
            expect(TimeRecord.last.assigned_date).to eq(current_day)
          end
        end

        it "should stop other active tasks" do
          travel_to current_day do
            active_time_record = create(:time_record, time_start: Time.now, user: current_user)
            expect_any_instance_of(TimeRecord).to receive(:stop).once
            result
          end
        end

        context "when passed start_time flag is false" do
          let(:start_task) { false }

          it "shouldn't set time_start" do
            result
            expect(TimeRecord.last.time_start).to be_nil
          end

          it "shouldn't stop other active tasks" do
            active_time_record = create(:time_record, time_start: Time.now, user: current_user)
            expect_any_instance_of(TimeRecord).to_not receive(:stop)
            result
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
