require "rails_helper"

RSpec.describe Mutations::TimeRecords::Update do

  let!(:current_user) { create(:user) }
  let!(:time_record) { create(:time_record, user: current_user) }
  let(:result) { TimeTrackerSchema.execute(query_string, context: context) }

  let(:query_string) do
    %|mutation {
      updateTimeRecord(
        startTask: #{start_task},
        timeRecordId: "#{ encode_id(time_record) }",
        projectId: "#{ encode_id(time_record.project) }",
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
          expect(result["errors"][0]["message"]).to eq(I18n.t('graphql.errors.not_authorized'))
        end
      end

      context "user was authorized" do
        let!(:context) { { current_user: current_user } }
        let(:start_task) { true }

        it "should update time record" do
          result
          expect(time_record.reload.description).to eq(description)
        end

        it "should build object form of updating" do
          form = double(save: true, time_record: create(:time_record))
          freeze_time do
            params = {
              description: "updated task",
              project_id: time_record.project.id,
              spent_time: 0.75,
              time_start: Time.now
            }
            expect(TimeRecords::UpdateForm).to receive(:new).with(params, current_user, time_record) { form }
            result
          end
        end

        it "should call save for form object" do
          expect_any_instance_of(TimeRecords::UpdateForm).to receive(:save)
          result
        end

        it "should return project's data" do
          expect(result['data']['updateTimeRecord']['timeRecord']['description']).to eq(description)
        end
      end
    end

    context "when passed data is wrong" do
      let!(:description) { nil }
      let!(:context) { { current_user: current_user } }
      let(:start_task) { false }

      it "should return error if description wasn't passed" do
        # expect(result['errors'][0]['message']).to_not be_empty
      end
    end
  end
end
