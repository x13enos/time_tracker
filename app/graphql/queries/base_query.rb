module Queries
  class BaseQuery < GraphQL::Schema::Resolver

    def authorize(object)
      PolicyExecutor.new(object, context[:current_user], path).perform
    end

  end
end
