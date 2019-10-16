class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise GraphQL::ExecutionError, "User must be logged in" unless user
    @user = user
    @record = record
  end

  private

  def record_belongs_to_user?
    record.user_id == user.id
  end

end
