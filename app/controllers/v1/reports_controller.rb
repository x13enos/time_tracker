class V1::ReportsController < V1::BaseController
  def index
    select_user
    select_time_records
    if params[:pdf].present?
      report_generator = ReportGenerator.new(@time_records, converted_dates, @user)
      render json: { link: report_generator.perform }
    else
      render template: '/v1/time_records/index.json.jbuilder', locals: { time_records: @time_records }
    end
  end

  private

  def converted_dates
    @converted_dates ||= {
      from: params[:from_date].convert_to_date_time,
      to: params[:to_date].convert_to_date_time
    }
  end

  def select_user
    @user = current_user.admin? ? User.find(params[:user_id]) : current_user
  end

  def select_time_records
    @time_records = @user.time_records
      .where("assigned_date BETWEEN ? AND ?", converted_dates[:from], converted_dates[:to])
      .order(created_at: :desc)
  end
end
