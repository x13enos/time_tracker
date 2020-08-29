require 'rails_helper'

RSpec.describe User, type: :model do
  context 'associations' do
    subject { build(:users_workspace) }

    it { should belong_to(:workspace) }
    it { should belong_to(:user) }
  end
end
