require 'rails_helper'

RSpec.describe Tag, type: :model do

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:workspace_id) }
  end

  context 'associations' do
    it { should have_and_belong_to_many(:time_records) }
    it { should belong_to(:workspace) }
  end

  describe '.by_workspace' do
    it "should return list of tags selected by passed workspace" do
      workspace = create(:workspace)
      tag1 = create(:tag, workspace: workspace)
      tag2 = create(:tag)
      tag3 = create(:tag, workspace: workspace)

      expect(Tag.by_workspace(workspace.id)).to include(tag1, tag3)
      expect(Tag.by_workspace(workspace.id).count).to eq(2)
    end
  end
end
