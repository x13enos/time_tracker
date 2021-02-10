module ExtendedHelpers
  def login_user(role)
    before(:each) do
     @current_user =  FactoryBot.create(:user, role)
     allow(controller).to receive(:current_user) { @current_user }
     allow(controller).to receive(:current_workspace_id) { @current_user.active_workspace_id }
     controller.instance_variable_set(:@current_workspace_id, @current_user.active_workspace_id)
    end
  end

end

module IncludedHelpers
  def login_user_with_workspace(role, workspace)
    @current_user =  FactoryBot.create(:user, role, active_workspace: workspace)
    allow(controller).to receive(:current_user) { @current_user }
    allow(controller).to receive(:current_workspace_id) { workspace.id }
    controller.instance_variable_set(:@current_workspace_id, workspace.id)
  end

  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale,
      timezone: user.timezone,
      active_workspace_id: user.active_workspace_id,
      notification_settings: user.notification_settings
    }
  end

  def user_info_with_workspaces(user)
    user_info(user).merge({
      workspaces: [
        { id: user.workspaces.first.id, name: user.workspaces.first.name }
      ]
    }) 
  end
end

RSpec.configure do |config|
  config.extend ExtendedHelpers, type: :controller
  config.include IncludedHelpers, type: :controller
end
