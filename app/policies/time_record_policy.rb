class TimeRecordPolicy < ApplicationPolicy

  def create?
    user.present?
  end

end
