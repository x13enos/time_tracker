module Users
  class ChangeWorkspaceForm < Users::BaseForm

    def initialize(workspace_id, user)
      @user = user
      attributes = user.attributes.slice(*ATTRIBUTES)
      attributes.merge!({
        active_workspace_id: workspace_id,
        workspace_ids: user.workspace_ids
      })
      super(attributes)
    end


    def persist!
      user.update!(active_workspace_id: self.active_workspace_id)
    end

  end
end
