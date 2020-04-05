require 'rails_helper'

RSpec.describe Project, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should have_and_belong_to_many(:users) }
    it { should have_many(:time_records).dependent(:destroy) }

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
end
