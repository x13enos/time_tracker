class ProjectPolicy < ApplicationPolicy

  def index?
    user?
  end

  def create?
    user_is_admin?
  end

  def update?
    user_is_admin? && record_belongs_to_user?
  end

  def destroy?
    user_is_admin? && record_belongs_to_user?
  end

end
