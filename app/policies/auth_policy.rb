class AuthPolicy < ApplicationPolicy

  def destroy?
    user?
  end

end
