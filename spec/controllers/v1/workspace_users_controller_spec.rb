require 'rails_helper'

RSpec.describe V1::WorkspaceUsersController, type: :controller do
  def user_info(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      locale: user.locale
    }
  end

  describe "POST #create" do
    login_admin
    let!(:workspace) { create(:workspace) }

    before do
      workspace.users << @current_user
    end

    context "user already was created" do
      let!(:user) { create(:user) }

      it "should return success status if user was assigned to the workspace" do
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
        expect(response.body).to eq(user_info(user).to_json)
      end

      it "should return error message if user wasn't assigned to the project" do
        allow(@current_user).to receive_message_chain(:workspaces, :find) { workspace }
        allow(workspace).to receive_message_chain(:users, :<<).and_raise(ActiveRecord::StaleObjectError)
        post :create, params: { workspace_id: workspace.id, email: user.email, format: :json }
        expect(response.body).to eq({ error: I18n.t("workspaces.errors.user_was_not_invited") }.to_json)
      end
    end

    context "user wasn't created" do
      it "should return user's data if user was created" do
        post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json }
        expect(response.body).to eq(user_info(User.last).to_json)
      end

      it "should send an email to user if he was created" do
        mailer = double
        allow(UserMailer).to receive(:invitation_email) { mailer }
        expect(mailer).to receive(:deliver_now)
        post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json }
      end

      it "should add user to DB" do
        expect{ post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json } }.to change{ User.count }.from(1).to(2)
      end

      it "should add user to the current workspace" do
        post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json }
        expect(workspace.users).to include(User.find_by(email: "example@gmail.com"))
      end

      it "should set active workspace for new user" do
        post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json }
        expect(User.find_by(email: "example@gmail.com").active_workspace_id).to eq(workspace.id)
      end

      it "should generate and keep password for new user" do
        user = build(:user)
        allow(User).to receive(:new) { user }
        allow(SecureRandom).to receive(:urlsafe_base64) { "i3Sl4ro4" }
        post :create, params: { workspace_id: workspace.id, email: "example@gmail.com", format: :json }
        expect(user.reload.password == "i3Sl4ro4").to be_truthy
      end
    end
  end

  describe "DELETE #destroy" do
    login_admin
    let!(:workspace) { create(:workspace) }
    let(:user) { create(:user) }

    before do
      workspace.users << [@current_user, user]
    end

    it "should return success status if user was removed from project" do
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(response.body).to eq({ success: true }.to_json)
    end

    it "should remove user from list of workspace's users" do
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(workspace.reload.user_ids).to_not include(user.id)
    end

    it "should return error message if user wasn't removed from project" do
      allow(@current_user).to receive_message_chain(:workspaces, :find) { workspace }
      allow(workspace).to receive_message_chain(:users, :delete).and_raise(ActiveRecord::StaleObjectError)
      delete :destroy, params: { workspace_id: workspace.id, id: user.id, format: :json }
      expect(response.body).to eq({ error: I18n.t("workspaces.errors.user_was_not_removed") }.to_json)
    end
  end
end
