class TimeRecordPolicy < ApplicationPolicy
  def create?
    user?
  end

  def update?
    user? && record_belongs_to_user?
  end

  def delete?
    user? && record_belongs_to_user?
  end

  def daily?
    user?
  end

  def all?
    user?
  end
end
