class V1::TimeRecordsController < V1::BaseController
  def index
    @time_records = current_user.time_records
      .where("assigned_date = ?", params[:assigned_date].convert_to_date_time)
      .order(created_at: :desc)
  end

  def create
    handle_form(TimeRecords::CreateForm.new(prepared_params, current_user))
  end

  def update
    time_record = current_user.time_records.find(params[:id])
    handle_form(TimeRecords::UpdateForm.new(prepared_params, current_user, time_record))
  end

  def destroy
    time_record = current_user.time_records.find(params[:id])
    if time_record.delete
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: time_record }
    else
      render json: { errors: time_record.errors.full_messages }, status: 400
    end
  end

  private

  def handle_form(form)
    if form.save
      render partial: '/v1/time_records/show.json.jbuilder', locals: { time_record: form.time_record }
    else
      render json: { errors: form.errors.full_messages }, status: 400
    end
  end

  def time_record_params
    params.permit(:name, :email, :timezone, :password)
  end

  def prepared_params
    params[:assigned_date] = params[:assigned_date].convert_to_date if params[:assigned_date]
    permitted_params = params.permit(:project_id, :description, :spent_time, :assigned_date)
    permitted_params.merge({
      time_start: params[:start_task] ? Time.zone.now : nil
    })
  end
end
