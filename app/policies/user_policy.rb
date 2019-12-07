class UserPolicy < ApplicationPolicy

  def sign_up?
    user? && user.admin?
  end

  def sign_out?
    user?
  end

  def personal_info?
    user?
  end

  def update_profile?
    user?
  end

  def all?
    sign_up?
  end

end
