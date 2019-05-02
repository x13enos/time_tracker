module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    null false

    def authorize(object)
      PolicyExecutor.new(object, context[:current_user], path).perform
    end
  end
end
