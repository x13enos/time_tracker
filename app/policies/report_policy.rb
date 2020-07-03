class ReportPolicy < ApplicationPolicy

  def index?
    user?
  end

end
