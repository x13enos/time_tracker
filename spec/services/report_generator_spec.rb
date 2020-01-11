require "rails_helper"

RSpec.describe ReportGenerator do

  describe "perform" do
    let(:user) { create(:user) }
    let(:from_date) { Time.zone.local(2019, 10, 15) }
    let(:to_date) { Time.zone.local(2019, 10, 30) }
    let(:generator) { ReportGenerator.new({ user: user, from_date: from_date, to_date: to_date }) }
    let(:project) { create(:project) }

    before do
      travel_to Time.zone.local(2019, 10, 29)

      @time_record = create(:time_record, project: project, user: user, assigned_date: Time.zone.today, spent_time: 0.45)
      @time_record_2 = create(:time_record, project: project, created_at: Time.zone.now - 2.hour, assigned_date: Time.zone.today, spent_time: 1.44)
      @time_record_3 = create(:time_record, project: project, user: user, assigned_date: Time.zone.today)
      @time_record_4 = create(:time_record, project: project, user: user, created_at: Time.zone.now - 1.hour, assigned_date: Time.zone.today - 10.days, spent_time: 3.5)
      @time_record_5 = create(:time_record, project: project, user: user, assigned_date: Time.zone.today - 25.days)

      travel_back
    end

    it "should render partial and pass time records in locals" do
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      expect(ActionController::Base).to receive(:render).with({
        file: "pdfs/report",
        locals: {
          time_records: [@time_record, @time_record_3, @time_record_4],
          projects: [project],
          user: user,
          from_date: from_date,
          to_date: to_date
        }
      })
      generator.perform
    end

    it "should render pdf document from the html string" do
      pdf_service = double
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow(WickedPdf).to receive(:new) { pdf_service }
      expect(pdf_service).to receive(:pdf_from_string).with('string')
      generator.perform
    end

    it "should keep file in the public folder" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      generator.perform
      expect(File).to exist("#{Rails.root}/public/reports/report-#{uuid}.pdf")
    end

    it "should return link on downloading file" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      expect(generator.perform).to eq("#{ENV['HOST']}/reports/report-#{uuid}.pdf")
    end
  end
end
