require 'rails_helper'

RSpec.describe Users::CreateForm, type: :model do
  let!(:workspace) { create(:workspace) }

  context 'validations' do
    let!(:user_form) { Users::CreateForm.new(attributes_for(:user)) }
    before do
      user_form.workspace_ids = [user_form.active_workspace_id]
    end
    subject { user_form }


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
