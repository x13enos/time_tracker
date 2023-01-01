class ReportGenerator
  attr_accessor :report

  def initialize(time_records_data, user)
    @time_records_data = time_records_data
    @user = user
  end

  def link
    create_report
    ENV['HOST'] + "/reports/#{report.uuid}"
  end

  def file
    create_report
    report.file.download
  end

  private
  attr_reader :time_records_data, :user

  def render_report_from_template
    ActionController::Base.render(
      partial: "pdfs/report", locals: {
        user: user,
        time_records: time_records_data[:grouped_time_records],
        from_date: time_records_data[:converted_dates][:from],
        to_date: time_records_data[:converted_dates][:to],
        projects: time_records_data[:projects],
        total_time: time_records_data[:total_spent_time]
      }
    )
  end

  def create_report
    pdf = WickedPdf.new.pdf_from_string(render_report_from_template)
    @report = Report.create(user: user, uuid: SecureRandom.uuid)
    report.file.attach(
      io: StringIO.new(pdf),
      content_type: "application/pdf",
      filename: "#{user.name} #{time_records_data[:converted_dates][:from]} | #{time_records_data[:converted_dates][:to]}.pdf")
  end
end
