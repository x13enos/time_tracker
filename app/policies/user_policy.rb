class UserPolicy < ApplicationPolicy

  def sign_up?
    user.admin?
  end

end
