class WorkspacePolicy < ApplicationPolicy

  def index?
    user_is_admin?
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

  def invite_user?
    user_is_admin? && record_belongs_to_user?
  end

  def remove_user?
    user_is_admin? && record_belongs_to_user?
  end
end
