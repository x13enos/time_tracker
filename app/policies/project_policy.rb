class ProjectPolicy < ApplicationPolicy

  def create?
    user_is_admin?
  end

  def update?
    user_is_admin?
  end

  def delete?
    user_is_admin?
  end

  def assign_user?
    user_is_admin?
  end

  def single?
    user_is_admin?
  end

  def all?
    user?
  end

end
