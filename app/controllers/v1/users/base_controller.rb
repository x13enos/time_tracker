class V1::Users::BaseController < V1::BaseController
  skip_before_action :authenticate
  skip_after_action :set_token

  def update
    validate_updating_params or return
    handle_request
  end

  private

  def handle_request
    user = User.find_by(email: decode(params[:token].to_s))

    if user
      user.assign_attributes(user_params)
      if user.save!
        render json: { status: 'ok' }, status: 200
      else
        render json: { error: user.errors.full_messages }, status: 422
      end
    else
      render json: { error: I18n.t("passwords.invalid_token") }, status: 404
    end
  end

  def validate_attribute_on_presence(attribute)
    return false if params[attribute.to_sym].present?
    render(
      json: { error: I18n.t("passwords.#{attribute}_does_not_present") },
      status: 400
    )
  end
end
