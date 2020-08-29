require 'rails_helper'

RSpec.describe Users::UpdateForm, type: :model do
  let!(:workspace) { create(:workspace) }
  let!(:user) { create(:user, active_workspace_id: workspace.id) }

  context 'validations' do
    let!(:user_form) { Users::UpdateForm.new({ email: "new_email@gmail.com" }, user) }

    subject { user_form }

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
