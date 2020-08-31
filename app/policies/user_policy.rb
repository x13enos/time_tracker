class UserPolicy < ApplicationPolicy

  def index?
    user_is_manager?
  end

  def update?
    user?
  end

  def change_workspace?
    user?
  end

end
