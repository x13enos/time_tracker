class V1::TagsController < V1::BaseController
  def index
    authorize Tag
    @tags = Tag.by_workspace(current_workspace_id)
  end

  def create
    authorize Tag
    @tag = Tag.new(tag_params)
    @tag.workspace_id = current_workspace_id
    @tag.save
    generate_response
  end

  def update
    authorize tag
    tag.update(tag_params)
    generate_response
  end

  def destroy
    authorize tag
    tag.destroy
    generate_response
  end

  private

  def generate_response
    if tag.errors.any?
      render json: { errors: tag.errors }, status: 400
    else
      render partial: '/v1/tags/show.json.jbuilder', locals: { tag: tag }
    end
  end

  def tag
    @tag ||= Tag.by_workspace(current_workspace_id)
                .find(params[:id])
  end

  def tag_params
    params.permit(:name)
  end
end
