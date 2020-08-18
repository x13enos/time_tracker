class WorkspacePolicy < ApplicationPolicy

  def index?
    user?
  end

  def create?
    user?
  end

  def update?
    user? && workspace_belongs_to_user?
  end

  def destroy?
    user? && workspace_belongs_to_user?
  end

end
