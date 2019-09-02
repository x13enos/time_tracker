FactoryBot.define do

  factory :time_record do
    description { Faker::Lorem.word }
    association :user
    association :project
  end

end
