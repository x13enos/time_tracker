class V1::Users::PasswordsController < V1::Users::BaseController

  def create
    validate_attribute_on_presence('email') and return

    user = User.find_by(email: params[:email])
    if user.present?
      UserMailer.recovery_password_email(user).deliver_now
      render json: { status: 'ok' }, status: 200
    else
      render json: { error: I18n.t("passwords.user_not_found") }, status: 404
    end
  end

  private

  def validate_updating_params
    validate_attribute_on_presence('token') and return
    validate_attribute_on_presence('password') and return
    return true
  end

  def user_params
    params.permit(:password)
  end
end
