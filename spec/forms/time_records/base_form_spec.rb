require 'rails_helper'

RSpec.describe TimeRecords::BaseForm, type: :model do

  context 'validations' do
    let!(:time_record_form) { TimeRecords::BaseForm.new(attributes_for(:time_record)) }

    subject { time_record_form }

    it { is_expected.to validate_presence_of(:spent_time) }
    it { is_expected.to validate_presence_of(:assigned_date) }
  end

end
