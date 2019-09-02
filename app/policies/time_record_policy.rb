class TimeRecordPolicy < ApplicationPolicy

  def create?
    user.present?
  end

  def update?
    create? && record_belongs_to_user?
  end

  def delete?
    update?
  end

end
