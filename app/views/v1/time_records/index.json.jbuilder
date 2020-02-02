json.time_records @time_records do |time_record|
  json.(time_record, :id, :description, :project_id)
  if params[:from_date]
    json.project_name time_record.project.name
    json.user_name time_record.user.name
    json.assigned_date time_record.assigned_date
  end
  json.time_start time_record.time_start_as_epoch
  json.spent_time time_record.calculated_spent_time
end

if params[:from_date]
  json.total_spent_time @time_records.sum(:spent_time)
end
