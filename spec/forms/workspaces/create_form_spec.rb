require 'rails_helper'

RSpec.describe Workspaces::CreateForm, type: :model do
  let(:user) { create(:user) }

  context 'validations' do
    let!(:workspace_form) { Workspaces::CreateForm.new(attributes_for(:workspace), user) }

    subject { workspace_form }

    describe 'name' do
      it 'should validate presence of name' do
        workspace_form.name = nil
        workspace_form.valid?
        expect(workspace_form.errors[:name]).to_not be_empty
      end
    end

    describe 'number_of_user_workspaces' do
      context "having two parallel requests" do
        let(:request_threads) do
          2.times.map { Thread.new { Workspaces::CreateForm.new(attributes_for(:workspace), user).save } }
        end

        it 'should prevent race condition and create only one worskpace' do
          2.times { create(:users_workspace, user: user, role: UsersWorkspace.roles["owner"]) }

          expect do
            request_threads.each(&:join)
          end.to change { Workspace.count }.by(1)
        end
      end

      it 'should add error in case of having 3 or more personal workspaces for user' do
        3.times { |_| create(:users_workspace, user: user, role: UsersWorkspace.roles["owner"]) }
        workspace_form.valid?
        expect(workspace_form.errors[:base].join).to eq(I18n.t("workspaces.errors.can_not_more_workspaces"))
      end

      it 'should not add error in case of having 2 or less personal workspaces for user' do
        2.times { |_| create(:users_workspace, user: user, role: UsersWorkspace.roles["owner"]) }
        workspace_form.valid?
        expect(workspace_form.errors[:base]).to be_empty
      end
    end
  end

  describe "initialize" do
    it 'should assign user to the form' do
      workspace_form = Workspaces::CreateForm.new(attributes_for(:workspace), user)
      expect(workspace_form.user).to eq(user)
    end
  end

  describe "save" do
    let!(:workspace_form) { Workspaces::CreateForm.new(attributes_for(:workspace), user) }

    context "when form is valid" do
      before do
        allow(workspace_form).to receive(:valid?) { true }
      end

      it "should create new workspace" do
        expect{ workspace_form.save }.to change{ Workspace.count }.from(1).to(2)
      end

      it "should assign user to the workspace" do
        workspace_form.save
        entry = workspace_form.workspace.users_workspaces.last
        expect(entry.role).to eq("owner")
        expect(entry.user_id).to eq(user.id)
      end
    end

    context "when form is invalid" do
      it "should raise error" do
        allow(workspace_form).to receive(:valid?) { false }
        expect(workspace_form.save).to be_falsey
      end
    end

  end

end
