class Graphql::SchemaExecutor

  def initialize(params, headers)
    @params = params
    @headers = headers
  end

  def perform
    handle_graphql_request
  end

  private
  attr_reader :params, :headers

  def handle_graphql_request
    TimeTrackerSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
  end

  def query
    params[:query]
  end

  def variables
    Graphql::Variables.process(params[:variables])
  end

  def operation_name
    params[:operationName]
  end

  def context
    { current_user: Graphql::UserFinder.new(headers).perform }
  end

end
