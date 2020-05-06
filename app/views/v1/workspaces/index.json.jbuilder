json.array! @workspaces do |workspace|
  json.(workspace, :id, :name, :user_ids)
end
