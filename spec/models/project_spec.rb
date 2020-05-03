require 'rails_helper'

RSpec.describe Project, type: :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should have_and_belong_to_many(:users) }
    it { should have_many(:time_records).dependent(:destroy) }
    it { should belong_to(:workspace) }

    describe '#belongs_to_user?' do
      it "should return true if that belongs to the passed user" do
        user = create(:user)
        project = create(:project)
        project.users << user

        expect(project.belongs_to_user?(user.id)).to be_truthy
      end

      it "should return false if that doesn't belong to the passed user" do
        user = create(:user)
        project = create(:project)

        expect(project.belongs_to_user?(user.id)).to be_falsey
      end
    end
  end

  describe '.by_workspace' do
    it "should return list of projects selected by passed workspace" do
      workspace = create(:workspace)
      project1 = create(:project, workspace: workspace)
      project2 = create(:project)
      project3 = create(:project, workspace: workspace)

      expect(Project.by_workspace(workspace.id)).to include(project1, project3)
      expect(Project.by_workspace(workspace.id).count).to eq(2)
    end
  end
end
