class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def record_belongs_to_user?
    record.user_id == user.id
  end

end
