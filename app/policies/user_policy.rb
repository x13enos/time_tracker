class UserPolicy < ApplicationPolicy

  def index?
    user_is_admin?
  end

  def update?
    user?
  end

end
