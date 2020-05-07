require "rails_helper"

RSpec.describe ReportGenerator do
  let!(:admin) { create(:user, role: :admin) }
  let!(:workspace) { create(:workspace) }
  let!(:email) { "staff@gmail.com" }

  describe "perform" do
    context "user wasn't create before" do
      it "should create new user" do
        expect { AssignUserService.new(email, admin, workspace).perform }.to change { User.count }.from(1).to(2)
      end

      it "should create user with role - staff" do
        user = AssignUserService.new(email, admin, workspace).perform
        expect(user.reload.role).to eq("staff")
      end

      it "should keep pregenerated password" do
        allow(SecureRandom).to receive(:urlsafe_base64) { "i3Sl4ro4" }
        user = AssignUserService.new(email, admin, workspace).perform
        expect(user.reload.password == "i3Sl4ro4").to be_truthy
      end

      it "should set passed workspace as active for new user" do
        user = AssignUserService.new(email, admin, workspace).perform
        expect(user.reload.active_workspace).to eq(workspace)
      end

      it "should assign new user to passed workspace" do
        user = AssignUserService.new(email, admin, workspace).perform
        expect(workspace.user_ids).to include(user.id)
      end

      it "should send invitation email" do
        expect(UserMailer).to receive(:invitation_email) { double(deliver_now: true) }
        AssignUserService.new(email, admin, workspace).perform
      end
    end

    context "user was already created" do
      let!(:existed_user) { create(:user, email: "staff@gmail.com") }

      it "should return existed user" do
        allow(User).to receive(:find_by).with({ email: "staff@gmail.com" }) { existed_user }
        expect(AssignUserService.new(email, admin, workspace).perform).to eq(existed_user)
      end

      it "should assign user to passed workspace" do
        AssignUserService.new(email, admin, workspace).perform
        expect(workspace.user_ids).to include(existed_user.id)
      end

      it "should not create new user" do
        expect { AssignUserService.new(email, admin, workspace).perform }.to_not change { User.count }
      end

      it "should send email to user about assiging to new workspace" do
        expect(UserMailer).to receive(:assigning_to_workspace_email) { double(deliver_now: true) }
        AssignUserService.new(email, admin, workspace).perform
      end
    end
  end
end
