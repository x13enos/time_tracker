class V1::TimeRecordsController < V1::BaseController
  def index
    authorize TimeRecord
    current_date = params[:assigned_date].to_datetime
    @time_records = current_user.time_records
      .by_workspace(current_user.active_workspace_id)
      .where("assigned_date BETWEEN ? and ?", current_date.beginning_of_week, current_date.end_of_week)
      .order(created_at: :asc)
  end

  def create
    authorize TimeRecord
    handle_form(TimeRecords::CreateForm.new(prepared_params, current_user))
  end

  def update
    time_record = current_user
      .time_records
      .by_workspace(current_user.active_workspace_id)
      .find(params[:id])
    authorize time_record
    handle_form(TimeRecords::UpdateForm.new(prepared_params, current_user, time_record))
  end

  def destroy
    time_record = current_user
      .time_records
      .by_workspace(current_user.active_workspace_id)
      .find(params[:id])
    authorize time_record
    if time_record.delete
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: time_record }
    else
      render json: { error: time_record.errors.full_messages.join(", ") }, status: 400
    end
  end

  private

  def handle_form(form)
    if form.save
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: form.time_record }
    else
      render json: { error: form.errors.full_messages.join(", ") }, status: 400
    end
  end

  def time_record_params
    params.permit(:name, :email, :password)
  end

  def prepared_params
    params[:assigned_date] = params[:assigned_date].to_datetime if params[:assigned_date]
    permitted_params = params.permit(:project_id, :description, :spent_time, :assigned_date)
    permitted_params.merge({
      time_start: params[:start_task] ? Time.now : nil
    })
  end
end
