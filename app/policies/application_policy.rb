class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  private

  def user?
    if user
      true
    else
      raise GraphQL::ExecutionError.new(
        I18n.t('graphql.errors.not_authorized'),
        extensions: { "code" => "401" }
      )
    end
  end

  def record_belongs_to_user?
    record.user_id == user.id
  end

end
