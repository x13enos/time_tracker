module UsersWorkspaces
  class UpdateForm < BaseForm
    attr_accessor :role, :user_workspace
    validates :role, inclusion: { in: UsersWorkspace::CHANGEABLE_ROLES }
    validate :user_is_not_owner?

    def initialize(passed_attributes, user, current_workspace_id)
      @user_workspace = user.workspace_settings(current_workspace_id)
      @role = passed_attributes[:role]
    end

    def persist!
      update_user_details
    end

    private

    def update_user_details
      @user_workspace.update(role: role)
    end


    def user_is_not_owner?
      if @user_workspace.owner?
        errors.add(:role, I18n.t("users.errors.can_not_change_role_for_owner"))
      end
    end
  end
end
