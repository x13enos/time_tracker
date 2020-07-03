require 'rails_helper'

RSpec.describe TimeRecords::CreateForm, type: :model do
  let(:user) { create(:user) }

  context 'validations' do
    let!(:time_record_form) { TimeRecords::CreateForm.new(attributes_for(:time_record), user) }

    subject { time_record_form }

    describe 'only_todays_task_could_be_activated' do
      it "should raise error if assigned date isn't today and time start is present" do
        travel_to Time.zone.local(2019, 10, 29, 1, 0, 0)
        time_record_form.assigned_date = Date.today
        Time.zone = ActiveSupport::TimeZone[-5]
        time_record_form.time_start = Time.zone.now
        time_record_form.valid?
        expect(time_record_form.errors[:base]).to include(I18n.t("time_records.errors.only_todays_taks"))
        Time.zone = ActiveSupport::TimeZone[0]
        travel_back
      end

      it "shouldn't raise error if assigned date is today" do
        freeze_time do
          time_record_form.assigned_date = Date.today
          time_record_form.time_start = Time.now
          time_record_form.valid?
          expect(time_record_form.errors[:base]).to_not include(I18n.t("time_records.errors.only_todays_taks"))
        end
      end

      it "shouldn't raise error if time_start is nil" do
        freeze_time do
          time_record_form.assigned_date = Date.today - 2.days
          time_record_form.time_start = nil
          time_record_form.valid?
          expect(time_record_form.errors[:base]).to_not include(I18n.t("time_records.errors.only_todays_taks"))
        end
      end
    end

    describe "value_of_spent_time" do
      it "should not sum time records for all users and send error in case of having time more is than 24 hours" do
        freeze_time do
          create(:time_record, user: create(:user), spent_time: 1.5)
          time_record_form.spent_time = 23
          time_record_form.valid?
          expect(time_record_form.errors[:base]).to_not eq([I18n.t("time_records.errors.should_be_less_than_24_hours")])
        end
      end

      it "should add error if sum of spent time for task's day is more than 24 hours" do
        freeze_time do
          create(:time_record, user: user, spent_time: 1.5)
          time_record_form.spent_time = 23
          time_record_form.valid?
          expect(time_record_form.errors[:base]).to eq([I18n.t("time_records.errors.should_be_less_than_24_hours")])
        end
      end

      it "should not raise error if sum of spent time for task's day is less than 24 hours" do
        freeze_time do
          create(:time_record, spent_time: 1.5)
          time_record_form.spent_time = 22
          time_record_form.valid?
          expect(time_record_form.errors[:base]).to_not include(I18n.t("time_records.errors.should_be_less_than_24_hours"))
        end
      end
    end
  end

  describe "save" do
    let(:project) { create(:project) }
    let!(:time_record_form) { TimeRecords::CreateForm.new(attributes_for(:time_record), user) }

    context "when form is valid" do
      before do
        time_record_form.project_id = project.id
        allow(time_record_form).to receive(:valid?) { true }
      end

      it "should create new time record" do
        expect{ time_record_form.save }.to change{ TimeRecord.count }.from(0).to(1)
      end

      it "should assign new time record to form" do
        time_record_form.save
        expect(time_record_form.time_record).to be_present
      end

      it "should assign id of created time record to form" do
        time_record_form.save
        expect(time_record_form.id).to eq(TimeRecord.last.id)
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
        expect(time_record_form.save).to be_falsey
      end
    end

  end

end
