class V1::ReportsController < V1::BaseController
  def index
    authorize :report
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
      from: params[:from_date].to_i.convert_to_date_time,
      to: params[:to_date].to_i.convert_to_date_time
    }
  end

  def select_user
    @user = if current_user.admin? && params[:user_id].present?
      User.find(params[:user_id])
    else
      current_user
    end
  end

  def select_time_records
    @time_records = @user.time_records
      .joins(:project)
      .joins(:user)
      .where("assigned_date BETWEEN ? AND ?", converted_dates[:from], converted_dates[:to])
      .order(created_at: :desc)
  end
end
