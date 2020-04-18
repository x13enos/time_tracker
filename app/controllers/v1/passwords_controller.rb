class V1::PasswordsController < V1::BaseController
  skip_before_action :authenticate
  skip_after_action :set_token

  def forgot
    if params[:email].blank?
      return render json: { error: I18n.t("recovery_password.email_not_present") }, status: 400
    end

    user = User.find_by(email: params[:email])
    if user.present?
      UserMailer.recovery_password_email(user).deliver_now
      render json: { status: 'ok' }, status: 200
    else
      render json: { error: I18n.t("recovery_password.user_not_found") }, status: 404
    end
  end

  def reset
    validate_params or return

    user = User.find_by(email: decode(params[:token].to_s))
    if user
      user.password = params[:password].to_s
      if user.save!
        render json: { status: 'ok' }, status: 200
      else
        render json: { error: user.errors.full_messages }, status: 422
      end
    else
      render json: { error: I18n.t("recovery_password.invalid_token") }, status: 404
    end
  end

  private

  def validate_params
    if params[:token].blank?
      render(
        json: { error: I18n.t("recovery_password.token_not_present") },
        status: 400
      ) and return
    end

    if params[:password].blank?
      render(
        json: { error: I18n.t("recovery_password.password_not_present") },
        status: 400
      ) and return
    end

    if params[:password] != params[:confirm_password]
      render(
        json: { error: I18n.t("recovery_password.confirmation_password_does_not_match") },
        status: 400
      ) and return
    end

    return true
  end

end
