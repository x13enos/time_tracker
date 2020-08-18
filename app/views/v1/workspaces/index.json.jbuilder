json.array! @workspaces do |workspace|
  json.(workspace, :id, :name)
  json.owner @current_user.workspace_owner?(workspace.id)
end
