class V1::Users::RegistrationsController < V1::Users::BaseController
  include ViewHelpers

  def create
    @form = Users::RegistrateForm.new(user_params)
    if @form.save
      set_token(@form.user.reload)
      render_json_partial('/v1/auth/user.json.jbuilder', { user: @form.user })
    else
       render json: { errors: @form.errors }, status: 400
    end
  end

  private

  def user_params
    params.permit(:email, :password, :locale)
  end
end
