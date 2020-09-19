require "rails_helper"

RSpec.describe ReportsCleaner do
  describe "perform" do
    let!(:report) { create(:report, created_at: Time.now - 8.days) }
    let!(:report_2) { create(:report, created_at: Time.now - 5.days) }
    let!(:report_3) { create(:report) }

    it "should remove order which were created more than 7 days ago" do
      expect { ReportsCleaner.new.perform }.to change { Report.count }.from(3).to(2)
    end

    it "should remove files from expired reports" do
      reports = Report.where(id: [report_2.id, report_3.id])
      allow(Report).to receive(:where) { reports }
      reports.each do |report|
        expect(report.file).to receive(:purge)
      end
      ReportsCleaner.new.perform
    end
  end
end
