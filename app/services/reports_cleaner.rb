class ReportsCleaner
  attr_accessor :reports

  def perform
    select_expired_reports
    delete_reports
  end

  private

  def select_expired_reports
    @reports = Report.where("created_at < ?", Time.now - 7.days)
  end

  def delete_reports
    reports.each { |report| report.file.purge }
    reports.delete_all
  end
end
