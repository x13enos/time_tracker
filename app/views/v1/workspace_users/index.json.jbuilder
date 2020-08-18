json.array! @workspace.users do |user|
  json.(user, :id, :name, :email)
  json.role user.role(@workspace.id)
end
