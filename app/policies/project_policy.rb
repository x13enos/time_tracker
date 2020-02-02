class ProjectPolicy < ApplicationPolicy

  def index?
    user?
  end
  
end
