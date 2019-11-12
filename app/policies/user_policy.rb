class UserPolicy < ApplicationPolicy

  def sign_up?
    user? && user.admin?
  end

  def sign_out?
    user?
  end

end
