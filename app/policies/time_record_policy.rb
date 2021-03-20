class TimeRecordPolicy < ApplicationPolicy

  def index?
    user?
  end

  def active?
    user?
  end

  def create?
    user?
  end

  def update?
    user? && record_belongs_to_user?
  end

  def destroy?
    user? && record_belongs_to_user?
  end
  
end
