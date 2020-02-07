require 'rails_helper'

describe ProjectPolicy do

  context 'user is staff' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(user, Project) }

    it { is_expected.to permit_action(:index) }
  end

  context 'user was not found' do
    let(:user) { build(:user, role: :staff) }

    subject { described_class.new(nil, Project) }

    it { is_expected.to forbid_action(:index) }
  end
end
