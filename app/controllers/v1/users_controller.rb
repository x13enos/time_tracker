class V1::UsersController < V1::BaseController
  def index
    authorize User
    @users = User.all
  end

  def create
    authorize User
    user = User.new(user_params)
    password = SecureRandom.urlsafe_base64(8)
    user.password = password
    if user.save
      send_email(user, password)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user.reload }
    else
      render json: { error: user.errors.values.join(", ") }, status: 400
    end
  end

  def update
    authorize User
    if current_user.update(user_params)
      render partial: '/v1/users/show.json.jbuilder', locals: { user: current_user.reload }
    else
      render json: { error: current_user.errors.values.join(", ") }, status: 400
    end
  end

  def destroy
    authorize User
    user = User.find(params[:id])
    if user.destroy
      render partial: '/v1/users/show.json.jbuilder', locals: { user: user }
    else
      render json: { error: user.errors.values.join(", ") }, status: 400
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :locale)
  end

  def send_email(user, password)
    UserMailer.invitation_email(user, password).deliver_now
  end
end
