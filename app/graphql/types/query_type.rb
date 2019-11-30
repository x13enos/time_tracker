module Types
  class QueryType < Types::BaseObject
    #Users
    field :personal_info, resolver: Queries::Users::PersonalInfo

    #Projects
    field :all_projects, resolver: Queries::Projects::All
    field :project, resolver: Queries::Projects::Single

    #Time records
    field :all_time_records, resolver: Queries::TimeRecords::All
  end
end
