class ProjectPolicy < ApplicationPolicy

  def index?
    user?
  end

  def create?
    user_is_manager?
  end

  def update?
    user_is_manager? && record_belongs_to_user?
  end

  def destroy?
    user_is_manager? && record_belongs_to_user?
  end

end
