class ReportGenerator

  def initialize(time_records, dates, user)
    @time_records = time_records
    @dates = dates
    @user = user
  end

  def perform
    generate_report
    link
  end

  private
  attr_reader :dates, :time_records, :user

  def generate_report
    pdf = WickedPdf.new.pdf_from_string(render_report_from_template)
    @file_name = "report-#{SecureRandom.uuid}.pdf"
    File.open(Rails.root.join('public/reports/', @file_name), 'wb') do |file|
      file << pdf
    end
  end

  def render_report_from_template
    ActionController::Base.render(
      file: "pdfs/report", locals: {
        user: user,
        time_records: time_records,
        from_date: dates[:from],
        to_date: dates[:to],
        projects: time_records.map(&:project).uniq
      }
    )
  end

  def link
    ENV['HOST'] + "/reports/#{ @file_name }"
  end
end
