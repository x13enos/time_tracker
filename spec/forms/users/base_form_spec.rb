require 'rails_helper'

RSpec.describe Users::BaseForm, type: :model do

  context 'validations' do
    let!(:user) { Users::BaseForm.new(attributes_for(:user)) }
    before do
      user.workspace_ids = [user.active_workspace_id]
    end
    subject { user }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:active_workspace_id) }
    it { is_expected.to allow_value('user@gmail.com').for(:email) }
    it { is_expected.to_not allow_value('usergmail.com').for(:email) }
    it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(32) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_inclusion_of(:locale).in_array(User::SUPPORTED_LANGUAGES) }

    describe "active_workspace_is_one_of_users_workspaces" do
      let!(:active_workspace) { create(:workspace) }
      let(:user) { Users::BaseForm.new(attributes_for(:user)) }
      it "should add error if active workspace is not in list of user's workspaces" do
        user.workspace_ids = [active_workspace.id]
        user.save
        expect(user.errors[:active_workspace_id]).to include(I18n.t("users.errors.active_workspace_is_invalid"))
      end
    end
  end

end
