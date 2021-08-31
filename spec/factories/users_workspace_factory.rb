FactoryBot.define do

  factory :users_workspace do
    role { :staff }
    association :user
    association :workspace
  end

end
