class ReportGenerator

  def initialize(time_records_data, user)
    @time_records_data = time_records_data
    @user = user
  end

  def link
    generate_report
    ENV['HOST'] + "/reports/#{ @file_name }"
  end

  def file
    generate_report
  end

  private
  attr_reader :time_records_data, :user

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
        time_records: time_records_data[:grouped_time_records],
        from_date: time_records_data[:converted_dates][:from],
        to_date: time_records_data[:converted_dates][:to],
        projects: time_records_data[:projects],
        total_time: time_records_data[:total_spent_time]
      }
    )
  end
end
