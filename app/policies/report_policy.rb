class ReportPolicy < ApplicationPolicy

  def generate?
    user?
  end

end
