require "rails_helper"

RSpec.describe Notifiers::Email do
  let(:user) { create(:user) }

  describe "assign_user_to_project" do
    let!(:notifier) { Notifiers::Email.new(user, { project: "project" }) }

    it "should build email" do
      mail = double(deliver_now: true)
      expect(UserMailer).to receive(:assign_user_to_project).with(user, "project") { mail }
      notifier.assign_user_to_project
    end

    it "should send email to user" do
      mail = double
      allow(UserMailer).to receive(:assign_user_to_project) { mail }
      expect(mail).to receive(:deliver_now)
      notifier.assign_user_to_project
    end
  end
end
