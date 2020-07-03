json.(time_record, :id, :description, :project_id, :tag_ids)
json.time_start time_record.time_start_as_epoch
json.spent_time time_record.calculated_spent_time
json.assigned_date time_record.assigned_date.strftime("%d/%m/%Y")
