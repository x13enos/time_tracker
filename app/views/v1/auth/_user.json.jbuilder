json.partial! 'v1/users/show', locals: { user: user }
json.workspaces user.workspaces, :id, :name
