class V1::ReportsController < V1::BaseController
  def index
    authorize :report
    select_user
    @time_records_data = TimeRecordsSelector.new(params, @user).perform
    if params[:pdf].present?
      report_generator = ReportGenerator.new(@time_records_data, @user)
      render json: { link: report_generator.perform }
    end
  end

  private

  def select_user
    @user = if current_user.admin? && params[:user_id].present?
      User.find_by(id: params[:user_id])
    else
      current_user
    end
  end

end
