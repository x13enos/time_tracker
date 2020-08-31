require "rails_helper"

RSpec.describe UserNotifier do
  let(:user) { create(:user) }

  describe ".initialize" do
    let!(:notifier) do
      UserNotifier.new(
        user: user,
        notification_type: :approve_period,
        additional_data: { period: "period" }
      )
    end

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
    let!(:notifier) do
      UserNotifier.new(
        user: user,
        notification_type: :assign_user_to_project,
        additional_data: { period: "period" }
      )
    end

    it "should user I18n for using user's locale during the creating of notifications" do
      allow(Notifiers::Email).to receive(:new) { double(assign_user_to_project: true) }
      expect(I18n).to receive(:with_locale).with(user.locale, &Proc.new { notifier.send(:notifications) })
      notifier.perform
    end

    it "should call mail notifier and use appropriated method" do
      user.workspace_settings.update(notification_rules: ["email_assign_user_to_project"])
      email_notifier = double
      allow(Notifiers::Email).to receive(:new).with(user, { period: "period" }) { email_notifier }
      expect(email_notifier).to receive(:assign_user_to_project)
      notifier.perform
    end

    it "should not call mail notifier if user doesn't enable notification for that" do
      notifier = UserNotifier.new(
        user: user,
        notification_type: :non_existed_method,
        additional_data: { period: "period" }
      )
      expect(Notifiers::Email).not_to receive(:new)
      notifier.perform
    end
  end
end
