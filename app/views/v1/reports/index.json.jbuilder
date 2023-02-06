json.time_records @time_records_data[:grouped_time_records] do |time_records_block|
  json.array! time_records_block do |time_record|
    json.(time_record, :id, :description, :project_id)
    json.project_name time_record.project&.name
    json.user_name time_record.user.name
    json.tags time_record.tags.pluck(:name)
    json.assigned_date time_record.assigned_date.strftime("%d-%m-%Y")
    json.time_start time_record.time_start_as_epoch
    json.spent_time time_record.calculated_spent_time
  end
end

json.total_spent_time @time_records_data[:total_spent_time]
