require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@gmail.com').for(:email) }
    it { should_not allow_value('usergmail.com').for(:email) }

    describe "length_password" do
      it "should return error if length less than 8" do
        user = build(:user, password: '1111')
        user.valid?
        expect(user.errors.messages[:password]).to include("is too short (minimum is 8 characters)")
      end

      it "should return error if length more than 32" do
        user = build(:user, password: '111111111111111111111111111111111111')
        user.valid?
        expect(user.errors.messages[:password]).to include("is too long (maximum is 32 characters)")
      end
    end
  end
end
