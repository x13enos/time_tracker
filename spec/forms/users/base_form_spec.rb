require 'rails_helper'

RSpec.describe Users::BaseForm, type: :model do

  context 'validations' do
    let!(:user) { Users::BaseForm.new(attributes_for(:user)) }
    before do
      user.workspace_ids = [user.active_workspace_id]
    end
    subject { user }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('user@gmail.com').for(:email) }
    it { is_expected.to_not allow_value('usergmail.com').for(:email) }
    it { is_expected.to validate_length_of(:password).is_at_least(8).is_at_most(32) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_inclusion_of(:locale).in_array(User::SUPPORTED_LANGUAGES) }
    
  end
end
