class TimeRecordPolicy < ApplicationPolicy
  def create?
    user?
  end

  def update?
    create? && record_belongs_to_user?
  end

  def delete?
    update?
  end

  def daily?
    create?
  end

  def all?
    create?
  end
end
