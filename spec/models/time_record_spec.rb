require 'rails_helper'

RSpec.describe TimeRecord, type: :model do

  describe 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:spent_time) }
    it { should validate_presence_of(:assigned_date) }

    it { should belong_to(:user) }
    it { should belong_to(:project) }
  end

end
