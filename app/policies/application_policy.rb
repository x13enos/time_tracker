class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def user?
    user.present?
  end

  def user_is_admin?
    user? && user.try(:admin?)
  end

  def record_belongs_to_user?
    if record.has_attribute?(:user_id)
      record.user_id == user.id
    else
      record.user_ids.include?(user.id)
    end
  end

end
