class UserPolicy < ApplicationPolicy

  def index?
    user_is_manager?
  end

  def update?
    user?
  end

end
