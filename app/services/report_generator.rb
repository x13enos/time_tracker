class ReportGenerator

  def initialize(params)
    @params = params
  end

  def perform
    select_time_records
    generate_report
    link
  end

  private
  attr_reader :params

  def select_time_records
    @time_records = params[:user].time_records.
      where("assigned_date BETWEEN ? AND ?", params[:from_date], params[:to_date]).
      order(created_at: :desc)
  end

  def generate_report
    html_string = ActionController::Base.render(file: "pdfs/report", locals: { time_records: @time_records })
    pdf = WickedPdf.new.pdf_from_string(html_string)
    @file_name = "report-#{SecureRandom.uuid}.pdf"
    File.open(Rails.root.join('public/reports/', @file_name), 'wb') do |file|
      file << pdf
    end
  end

  def link
    ENV['HOST'] + "/reports/#{ @file_name }"
  end
end
