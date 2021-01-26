require 'rails_helper'

RSpec.describe Users::RegistrateForm, type: :model do
  context 'validations' do
    let!(:user_form) { Users::RegistrateForm.new(attributes_for(:user)) }
    subject { user_form }

    it { should validate_presence_of(:timezone) }

    describe 'email_is_unique?' do
      let(:workspace) { create(:workspace) }

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
      Users::RegistrateForm.new({
        email: "special_user@gmail.com",
        password: "11111111",
        locale: "en"
      })
    end

    it "should create new user" do
      expect { form.persist! }.to change { User.count }.from(0).to(1)
    end

    it "should create new workspace" do
      expect { form.persist! }.to change { Workspace.count }.from(0).to(1)
    end

    it "should set the default name for user's workspace" do
      form.persist!
      expect(Workspace.last.name).to eq("special_user")
    end

    it "should set the newest workspace as user's active one" do
      form.persist!
      expect(User.last.active_workspace_id).to eq(Workspace.last.id)
    end

    it "should update user's workspace settings" do
      form.persist!
      workspace_settings = User.last.workspace_settings.slice(:notification_rules, :role)
      expect(workspace_settings).to eq({ "notification_rules" => ["email_assign_user_to_project"], "role" => "owner" })
    end

    it "should send email to user" do
      user = create(:user)
      allow(User).to receive(:create!) { user }
      expect(UserMailer).to receive(:welcome_email).with(user) { double(deliver_now: true) }
      form.persist!
    end
  end
end