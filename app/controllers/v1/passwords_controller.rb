class V1::PasswordsController < V1::BaseController
  skip_before_action :authenticate
  skip_after_action :set_token

  def new
    validate_attribute_on_presence('email') and return

    user = User.find_by(email: params[:email])
    if user.present?
      UserMailer.recovery_password_email(user).deliver_now
      render json: { status: 'ok' }, status: 200
    else
      render json: { error: I18n.t("passwords.user_not_found") }, status: 404
    end
  end

  def create
    validate_creating_params or return
    handle_request { |user| user.assign_attributes(user_params) }
  end

  def update
    validate_updating_params or return
    handle_request { |user| user.password = params[:password].to_s }
  end

  private

  def handle_request
    user = User.find_by(email: decode(params[:token].to_s))

    if user
      yield(user)
      if user.save!
        render json: { status: 'ok' }, status: 200
      else
        render json: { error: user.errors.full_messages }, status: 422
      end
    else
      render json: { error: I18n.t("passwords.invalid_token") }, status: 404
    end
  end

  def validate_creating_params
    validate_attribute_on_presence('token') and return
    validate_attribute_on_presence('name') and return
    validate_attribute_on_presence('password') and return
    return true
  end

  def validate_updating_params
    validate_attribute_on_presence('token') and return
    validate_attribute_on_presence('password') and return

    if params[:password] != params[:confirm_password]
      render(
        json: { error: I18n.t("passwords.confirmation_password_does_not_match") },
        status: 400
      ) and return
    end

    return true
  end

  def validate_attribute_on_presence(attribute)
    return false if params[attribute.to_sym].present?
    render(
      json: { error: I18n.t("passwords.#{attribute}_does_not_present") },
      status: 400
    )
  end

  def user_params
    params.permit(:name, :password)
  end
end
