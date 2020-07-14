FactoryBot.define do

  factory :user do
    before(:create) do |object|
      if object.active_workspace_id.nil?
        workspace = create(:workspace)
        object.workspaces << workspace
        object.active_workspace = workspace
      end
    end

    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "password" }

    trait :admin do
      role { :admin }
      id { 100 }
    end

    trait :staff do
      role { :staff }
      id { 101 }
    end
  end

end
