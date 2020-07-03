class V1::Users::InvitationsController < V1::Users::BaseController

  private

  def validate_updating_params
    validate_attribute_on_presence('token') and return
    validate_attribute_on_presence('name') and return
    validate_attribute_on_presence('password') and return
    return true
  end

  def user_params
    params.permit(:name, :password)
  end
end
