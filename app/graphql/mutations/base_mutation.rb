module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    def authorize(object)
      PolicyExecutor.new(object, context[:current_user], path).perform
    end

    def handle_invalid_record_message(exception)
      exception.record.errors.messages.values.flatten.join(", ")
    end
  end
end
