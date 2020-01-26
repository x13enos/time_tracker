class V1::TimeRecordsController < V1::BaseController
  def index
    @time_records = current_user.time_records.where(assigned_date_condition).order(created_at: :desc)
  end

  private

  def time_record_params
    params.permit(:name, :email, :timezone, :password)
  end

  def assigned_date_condition
    if params[:assigned_date]
      "assigned_date = '#{ params[:assigned_date].convert_to_date_time }'"
    else
      "assigned_date BETWEEN '#{ params[:from_date].convert_to_date_time }' AND '#{ params[:to_date].convert_to_date_time }'"
    end
  end
end
