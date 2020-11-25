FactoryBot.define do

  factory :tag do
    name     { Faker::Lorem.unique.word }
    association :workspace
  end

end
