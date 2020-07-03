require 'rails_helper'

RSpec.describe User, type: :model do

  context 'validations' do
    subject { build(:user, password: nil) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:active_workspace_id) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@gmail.com').for(:email) }
    it { should_not allow_value('usergmail.com').for(:email) }
    it { should validate_length_of(:password).is_at_least(8).is_at_most(32) }
    it { should validate_presence_of(:locale) }
    it { should validate_inclusion_of(:locale).in_array(User::SUPPORTED_LANGUAGES) }
  end

  context 'associations' do
    subject { build(:user, password: nil) }

    it { should have_and_belong_to_many(:projects) }
    it { should have_and_belong_to_many(:workspaces) }
    it { should have_many(:time_records).dependent(:destroy) }
    it { should belong_to(:active_workspace).class_name("Workspace").with_foreign_key(:active_workspace_id) }
  end

end
