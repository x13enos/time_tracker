json.array! @projects do |project|
  json.(project, :id, :name, :user_ids)
end
