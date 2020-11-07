require 'rails_helper'

RSpec.describe Workspace, type: :model do

  describe 'validations' do
    subject { build(:workspace) }

    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    subject { build(:workspace) }

    it { should have_many(:users_workspaces).dependent(:destroy) }
    it { should have_many(:users).through(:users_workspaces) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:time_records).through(:projects) }
  end

  describe '#belongs_to_user?' do
    it "should return true if that belongs to the passed user" do
      user = create(:user)
      workspace = create(:workspace)
      workspace.users << user

      expect(workspace.belongs_to_user?(user.id)).to be_truthy
    end

    it "should return false if that doesn't belong to the passed user" do
      user = create(:user)
      workspace = create(:workspace)

      expect(workspace.belongs_to_user?(user.id)).to be_falsey
    end
  end
end
