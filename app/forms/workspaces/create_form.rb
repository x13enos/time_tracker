module Workspaces
  class CreateForm < BaseForm
    attr_accessor :name, :user, :workspace
    validates :name, presence: true
    validate :number_of_user_workspaces
    

    def initialize(attributes, user)
      @user = user
      super(attributes)
    end

    def save
      if valid?
        create_workspace
        assign_user_to_workspace_as_owner
        true
      else
        false
      end
    end

    private

    def create_workspace
      @workspace = Workspace.create(as_json.slice("name"))
    end


    def number_of_user_workspaces
      if UsersWorkspace.where(user_id: user.id, role: UsersWorkspace.roles["owner"]).count >= 3
        errors.add(:base, I18n.t("workspaces.errors.can_not_more_workspaces"))
      end
    end

    def assign_user_to_workspace_as_owner
      UsersWorkspace.create(workspace_id: @workspace.id, role: "owner", user_id: @user.id)
    end
  end
end
