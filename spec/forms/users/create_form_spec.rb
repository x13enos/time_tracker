require 'rails_helper'

RSpec.describe Users::CreateForm, type: :model do
  let!(:workspace) { create(:workspace) }

  context 'validations' do
    let!(:user_form) { Users::CreateForm.new(attributes_for(:user)) }
    before do
      user_form.workspace_ids = [user_form.active_workspace_id]
    end
    subject { user_form }
    it { is_expected.to validate_presence_of(:active_workspace_id) }

    describe 'email_is_unique?' do
      it "should add error if user with this email already existed" do
        create(:user, active_workspace: workspace, email: user_form.email)
        user_form.valid?
        expect(user_form.errors.messages[:email]).to include(I18n.t("users.errors.email_uniqueness"))
      end

      it "should not add error if this email is unique for app" do
        user_form.valid?
        expect(user_form.errors.messages[:email]).to_not include(I18n.t("users.errors.email_uniqueness"))
      end
    end

    describe "active_workspace_is_one_of_users_workspaces" do
      let!(:active_workspace) { create(:workspace) }
      
      it "should add error if active workspace is not in list of user's workspaces" do
        user_form.workspace_ids = [active_workspace.id]
        user_form.valid?
        expect(user_form.errors[:active_workspace_id]).to include(I18n.t("users.errors.active_workspace_is_invalid"))
      end
    end
  end

  describe "persist!" do
    let(:form) do
      Users::CreateForm.new({
        email: "user@gmail.com",
        active_workspace_id: workspace.id,
        workspace_ids: [workspace.id]
      })
    end

    it "should create new user for passed workspace" do
      expect { form.persist! }.to change { User.count }.from(0).to(1)
    end

    it "should update notification settings for active workspace" do
      form.persist!
      expect(UsersWorkspace.last.notification_rules).to eq(["email_assign_user_to_project"])
    end
  end

end
