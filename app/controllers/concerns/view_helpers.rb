module ViewHelpers
  extend ActiveSupport::Concern
  prepend TimeTrackerExtension::ViewHelpers if EXTENSION_ENABLED

  def render_json_partial(view_path, locals = {})
    render partial: view_path, locals: locals
  end

end
