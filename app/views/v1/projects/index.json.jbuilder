json.array! @projects do |project|
  json.(project, :id, :name, :user_ids, :regexp_of_grouping)
end
