json.array! @users do |user|
  json.(user, :id, :name, :email)
end
