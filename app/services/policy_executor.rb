class PolicyExecutor

  def initialize(object, current_user, path)
    @object = object
    @current_user = current_user
    @path = path
  end

  def perform
    select_policy_class
    check_if_action_can_be_authorized
    raise_error_if_unauthorized
  end

  private
  attr_reader :object, :current_user, :path, :policy, :result, :object_name

  def select_policy_class
    name = select_name_from_object
    @policy = Object.const_get("#{name}Policy")
  end

  def select_name_from_object
    @object_name = if object.is_a?(String)
                    object.to_s.camelcase
                  else
                    object.class.to_s
                  end
  end

  def action
    pure_action.underscore + "?"
  end

  def pure_action
    path.gsub(/#{object_name}/, "")
  end

  def check_if_action_can_be_authorized
    @result = policy.new(current_user, object).send(action)
  end

  def raise_error_if_unauthorized
    unless result
      raise GraphQL::ExecutionError.new("You are not authorized to perform this action.")
    end
  end
end
