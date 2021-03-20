class V1::TimeRecordsController < V1::BaseController

  def index
    authorize TimeRecord
    @active_date = params[:assigned_date].to_datetime

    @time_records = current_user.time_records
      .by_workspace(current_workspace_id)
      .where("assigned_date BETWEEN ? and ?", @active_date.beginning_of_week, @active_date.end_of_week)
      .order(created_at: :asc)
  end

  def active
    authorize TimeRecord
    time_record = current_user.time_records.by_workspace(current_workspace_id).active.first
    if time_record
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: time_record }
    end
  end

  def create
    authorize TimeRecord
    handle_form(TimeRecords::CreateForm.new(prepared_params, current_user))
  end

  def update
    authorize time_record
    handle_form(TimeRecords::UpdateForm.new(prepared_params, current_user, time_record))
  end

  def destroy
    authorize time_record
    if time_record.delete
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: time_record }
    else
      render json: { errors: time_record.errors }, status: 400
    end
  end

  private

  def handle_form(form)
    if form.save
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: form.time_record }
    else
      render json: { errors: form.errors }, status: 400
    end
  end

  def time_record_params
    params.permit(:name, :email, :password)
  end

  def prepared_params
    params[:assigned_date] = params[:assigned_date].to_datetime if params[:assigned_date]
    permitted_params = params.permit(
      :start_task,
      :project_id,
      :description,
      :spent_time,
      :assigned_date,
      tag_ids: []
    )

    unless params[:start_task].nil?
      start_task_value = ActiveModel::Type::Boolean.new.cast(params[:start_task])
      permitted_params[:time_start] = start_task_value ? Time.now : nil
    end

    return permitted_params
  end

  def time_record
    @time_record ||= current_user
      .time_records
      .by_workspace(current_workspace_id)
      .find(params[:id])
  end
end
