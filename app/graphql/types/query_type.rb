module Types
  class QueryType < Types::BaseObject
    #Users

    #Projects
    field :all_projects, resolver: Queries::Projects::All
    field :project, resolver: Queries::Projects::Single

    #Time records
    field :daily_time_records, resolver: Queries::TimeRecords::Daily
    field :all_time_records, resolver: Queries::TimeRecords::All, connection: true 
  end
end
