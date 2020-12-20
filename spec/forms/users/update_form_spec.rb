require 'rails_helper'

RSpec.describe Users::UpdateForm, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:user) { create(:user, active_workspace_id: workspace.id) }

  context 'validations' do
    let!(:user_form) { Users::UpdateForm.new({ email: "new_email@gmail.com" }, user) }

    subject { user_form }
    it { is_expected.to validate_presence_of(:active_workspace_id) }

    describe 'email_is_unique?' do
      it "should add error if user with this email already existed" do
        create(:user, active_workspace: workspace, email: "new_email@gmail.com")
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
      Users::UpdateForm.new({
        email: "new_email@gmail.com",
        notification_rules: ["telegram_assign_user_to_project"]
      }, user)
    end

    it "should update user's attributes" do
      form.persist!
      expect(form.user.reload.email).to eq("new_email@gmail.com")
    end

    it "should update notification settings for active workspace" do
      form.persist!
      expect(form.user.workspace_settings.notification_rules).to eq(["telegram_assign_user_to_project"])
    end
  end

end
