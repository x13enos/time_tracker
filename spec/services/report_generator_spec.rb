require "rails_helper"

RSpec.describe ReportGenerator do
  let(:user) { create(:user) }
  let(:time_records) { [
    create(:time_record, project: project, user: user, assigned_date: Time.zone.today, spent_time: 0.45)
  ] }
  let(:time_records_data) {
    {
      grouped_time_records: [time_records],
      converted_dates: {
        from: Time.zone.local(2019, 10, 15),
        to: Time.zone.local(2019, 10, 30)
      },
      projects: [project],
      total_spent_time: 15
    }
  }
  let(:generator) { ReportGenerator.new(time_records_data, user) }
  let(:project) { create(:project) }

  describe "link" do
    it "should render partial and pass time records in locals" do
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      expect(ActionController::Base).to receive(:render).with({
        file: "pdfs/report",
        locals: {
          time_records: [time_records],
          projects: [project],
          user: user,
          from_date: Time.zone.local(2019, 10, 15),
          to_date: Time.zone.local(2019, 10, 30),
          total_time: 15
        }
      })
      generator.link
    end

    it "should render pdf document from the html string" do
      pdf_service = double
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow(WickedPdf).to receive(:new) { pdf_service }
      expect(pdf_service).to receive(:pdf_from_string).with('string')
      generator.link
    end

    it "should keep file in the public folder" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      generator.link
      expect(File).to exist("#{Rails.root}/public/reports/report-#{uuid}.pdf")
    end

    it "should return link on downloading file" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      expect(generator.link).to eq("#{ENV['HOST']}/reports/report-#{uuid}.pdf")
    end
  end

  describe "file" do
    it "should return report file" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      file = Tempfile.new
      allow(File).to receive(:open) { file }
      expect(generator.file).to eq(file)
    end
  end
end
