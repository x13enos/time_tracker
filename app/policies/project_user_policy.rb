class ProjectUserPolicy < ApplicationPolicy

  def create?
    user_is_admin? && record_belongs_to_user?
  end

  def destroy?
    user_is_admin? && record_belongs_to_user?
  end
end
