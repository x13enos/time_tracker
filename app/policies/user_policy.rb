class UserPolicy < ApplicationPolicy

  def sign_up?
    user_is_admin?
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
    user_is_admin?
  end

end
