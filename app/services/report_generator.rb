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
    @time_records = params[:user].time_records.includes(:project).
      where("assigned_date BETWEEN ? AND ?", params[:from_date], params[:to_date]).
      order(created_at: :desc)
  end

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
        user: params[:user],
        time_records: @time_records,
        from_date: params[:from_date],
        to_date: params[:to_date],
        projects: @time_records.map(&:project).uniq
      }
    )
  end

  def link
    ENV['HOST'] + "/reports/#{ @file_name }"
  end
end
