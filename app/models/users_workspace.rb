class UsersWorkspace < ApplicationRecord
  CHANGEABLE_ROLES = ["staff", "admin"]
  
  enum role: { staff: 0, admin: 1, owner: 2 }

  belongs_to :workspace
  belongs_to :user
end
