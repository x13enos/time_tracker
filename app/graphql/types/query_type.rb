module Types
  class QueryType < Types::BaseObject
    #Users

    #Projects
    field :all_projects, resolver: Queries::Projects::All
    field :project, resolver: Queries::Projects::Single
  end
end
