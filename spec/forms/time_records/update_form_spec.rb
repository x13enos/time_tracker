require 'rails_helper'

RSpec.describe TimeRecords::UpdateForm, type: :model do
  let(:user) { create(:user) }
  let(:time_record) { create(:time_record, spent_time: 0.25) }

  context 'validations' do
    let!(:time_record_form) { TimeRecords::UpdateForm.new({ spent_time: 0.75 }, user, time_record) }

    subject { time_record_form }

    describe 'only_todays_task_could_be_activated' do
      it "should raise error if assigned date isn't today and time start is present" do
        time_record_form.assigned_date = Date.today - 2.days
        time_record_form.time_start = Time.now
        expect{ time_record_form.valid? }.to raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.only_todays_taks"))
      end

      it "shouldn't raise error if assigned date is today" do
        freeze_time do
          time_record_form.assigned_date = Date.today
          time_record_form.time_start = Time.now
          expect{ time_record_form.valid? }.to_not raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.only_todays_taks"))
        end
      end

      it "shouldn't raise error if time_start is nil" do
        freeze_time do
          time_record_form.assigned_date = Date.today - 2.days
          time_record_form.time_start = nil
          expect{ time_record_form.valid? }.to_not raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.only_todays_taks"))
        end
      end
    end

    describe "value_of_spent_time" do
      it "should not call this validation if it is stop action" do
        freeze_time do
          time_record = create(:time_record, spent_time: 1.5, time_start: Time.now)
          time_record_form = TimeRecords::UpdateForm.new({ time_start: nil }, user, time_record)
          expect(time_record_form).to_not receive(:value_of_spent_time)
          time_record_form.valid?
        end
      end

      it "should not sum time records for all users and send error in case of having time more is than 24 hours" do
        freeze_time do
          create(:time_record, user: create(:user), spent_time: 1.5)
          time_record_form.spent_time = 23
          expect{ time_record_form.valid? }.to_not raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.should_be_less_than_24_hours"))
        end
      end

      it "should raise error if sum of spent time for task's day is more than 24 hours" do
        freeze_time do
          create(:time_record, user: user, spent_time: 1.5)
          time_record_form.spent_time = 23
          expect{ time_record_form.valid? }.to raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.should_be_less_than_24_hours"))
        end
      end

      it "should not raise error if sum of spent time for task's day is less than 24 hours" do
        freeze_time do
          create(:time_record, spent_time: 1.5)
          time_record_form.spent_time = 22
          expect{ time_record_form.valid? }.to_not raise_error(GraphQL::ExecutionError, I18n.t("time_records.errors.should_be_less_than_24_hours"))
        end
      end
    end
  end

  describe "save" do
    let!(:time_record_form) { TimeRecords::UpdateForm.new({ spent_time: 0.75 }, user, time_record) }

    context "when form is valid" do
      before do
        allow(time_record_form).to receive(:valid?) { true }
      end

      it "should update time record" do
        time_record_form.save
        expect(time_record.reload.spent_time).to eq(0.75)
      end

      it "should call method stop for each user's active time record except current one" do
        time_record = create(:time_record, user: user, time_start: Time.now)
        new_time_record = create(:time_record, user: user, time_start: Time.now)

        time_record_form.time_start = Time.now
        allow(user).to receive_message_chain(:time_records, :create) { new_time_record }
        allow(user).to receive_message_chain(:time_records, :active, :where) { [time_record] }
        expect(time_record).to receive(:stop)
        time_record_form.save
      end
    end

    context "when form is invalid" do
      it "should raise error" do
        allow(time_record_form).to receive(:valid?) { false }
        time_record_form.errors.add(:base, "Big Error")
        expect{ time_record_form.save }.to raise_error(GraphQL::ExecutionError, "Big Error")
      end
    end

  end

end
