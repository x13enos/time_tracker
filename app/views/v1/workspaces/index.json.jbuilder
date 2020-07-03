json.array! @workspaces do |workspace|
  json.(workspace, :id, :name)
  json.user_ids workspace.user_ids if @current_user.admin?
end
