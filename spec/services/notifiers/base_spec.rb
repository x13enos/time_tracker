require "rails_helper"

RSpec.describe Notifiers::Base do
  let(:user) { create(:user) }

  describe ".initialize" do
    let!(:notifier) { Notifiers::Base.new(user, { period: "period" }) }

    it "should assign user to the notifier's attributes" do
      expect(notifier.send(:user)).to eq(user)
    end

    it "should assign additional data to the notifier's attributes" do
      expect(notifier.send(:additional_data)).to eq({ period: "period" })
    end
  end
end
