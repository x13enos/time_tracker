class ProjectPolicy < ApplicationPolicy

  def create?
    user? && user.try(:admin?)
  end

  def update?
    create?
  end

  def delete?
    create?
  end

  def assign_user?
    create?
  end

  def single?
    create?
  end

  def all?
    user?
  end

end
