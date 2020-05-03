require 'rails_helper'

RSpec.describe Workspace, type: :model do

  describe 'validations' do
    subject { build(:workspace) }

    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    subject { build(:workspace) }

    it { should have_and_belong_to_many(:users) }
    it { should have_many(:projects).dependent(:destroy) }
  end

end
