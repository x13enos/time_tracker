FactoryBot.define do

  factory :tag do
    name     { Faker::Lorem.word }
    association :workspace
  end

end
