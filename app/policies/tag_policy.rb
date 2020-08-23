class TagPolicy < ApplicationPolicy

  def index?
    user?
  end

  def create?
    user_is_manager?
  end

  def update?
    user_is_manager?
  end

  def destroy?
    user_is_manager?
  end

end
