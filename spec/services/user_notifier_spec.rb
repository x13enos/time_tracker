require "rails_helper"

RSpec.describe UserNotifier do
  let(:user) { create(:user) }

  describe ".initialize" do
    let!(:notifier) { UserNotifier.new(user, :approve_period, { period: "period" }) }

    it "should assign user to the notifier's attributes" do
      expect(notifier.send(:user)).to eq(user)
    end

    it "should assign notification type to the notifier's attributes" do
      expect(notifier.send(:notification_type)).to eq(:approve_period)
    end

    it "should assign additional args to the notifier's attributes" do
      expect(notifier.send(:args)).to eq({ period: "period" })
    end
  end

  describe "perform" do
    let!(:notifier) { UserNotifier.new(user, :assign_user_to_project, { period: "period" }) }

    it "should user I18n for using user's locale during the creating of notifications" do
      allow(Notifiers::Email).to receive(:new) { double(assign_user_to_project: true) }
      expect(I18n).to receive(:with_locale).with(user.locale, &Proc.new { notifier.send(:notifications) })
      notifier.perform
    end

    it "should call mail notifier and use appropriated method" do
      email_notifier = double
      allow(Notifiers::Email).to receive(:new).with(user, { period: "period" }) { email_notifier }
      expect(email_notifier).to receive(:assign_user_to_project)
      notifier.perform
    end

    it "should not call mail notifier if it doesn't have appropriate method" do
      notifier = UserNotifier.new(user, :non_existed_method, { period: "period" })
      expect(Notifiers::Email).not_to receive(:new)
      notifier.perform
    end
  end
end
