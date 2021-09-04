json.(workspace, :id, :name, :user_ids)
json.owner @current_user.workspace_owner?(workspace.id)
