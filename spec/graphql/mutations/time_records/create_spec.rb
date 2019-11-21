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

        it "should return project's data" do
          travel_to current_day do
            expect(result['data']['createTimeRecord']['timeRecord']['description']).to eq('New task')
          end
        end

        it "should build object form of creating" do
          form = double(save: true, time_record: create(:time_record))
          travel_to current_day do
            params = {
              assigned_date: Date.today,
              description: "New task",
              project_id: project.id,
              spent_time: 0.75,
              time_start: Time.now
            }
            expect(TimeRecords::CreateForm).to receive(:new).with(params, current_user) { form }
            result
          end
        end

        it "should call save for form object" do
          expect_any_instance_of(TimeRecords::CreateForm).to receive(:save)
          result
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
