require 'rails_helper'

RSpec.describe Project, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it { should have_and_belong_to_many(:users) }
  end
end
