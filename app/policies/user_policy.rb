class UserPolicy < ApplicationPolicy

  def sign_up?
    user? && user.admin?
  end

end
