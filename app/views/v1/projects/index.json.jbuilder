json.array! @projects do |project|
  json.(project, :id, :name)
end
