require "rails_helper"

RSpec.describe ReportGenerator do
  let(:user) { create(:user) }
  let(:workspace) { user.active_workspace }
  let(:time_records) { [
    create(:time_record, workspace: workspace, user: user, assigned_date: Time.zone.today, spent_time: 0.45)
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
      allow(StringIO).to receive(:new) { Tempfile.new }
      generator.link
    end

    it "should render pdf document from the html string" do
      pdf_service = double
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow(WickedPdf).to receive(:new) { pdf_service }
      expect(pdf_service).to receive(:pdf_from_string).with('string')
      allow(StringIO).to receive(:new) { Tempfile.new }
      generator.link
    end

    it "should create order" do
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      allow(StringIO).to receive(:new) { Tempfile.new }
      expect { generator.link }.to change { Report.count }.from(0).to(1)
    end

    it "should return link on downloading file" do
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      allow(StringIO).to receive(:new) { Tempfile.new }
      expect(generator.link).to eq("#{ENV['HOST']}/reports/#{Report.last.uuid}")
    end
  end

  describe "file" do
    it "should return report file" do
      uuid = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid) { uuid }
      allow(ActionController::Base).to receive(:render) { 'string' }
      allow_any_instance_of(WickedPdf).to receive(:pdf_from_string)
      allow(StringIO).to receive(:new) { Tempfile.new }
      expect(generator.file).to eq(Report.last.file.download)
    end
  end
end
