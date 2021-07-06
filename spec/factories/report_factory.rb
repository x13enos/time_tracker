FactoryBot.define do

  factory :report do
    association :user

    uuid     { SecureRandom.uuid }
    file     { Rack::Test::UploadedFile.new("#{Rails.root}/spec/support/files/sample.pdf") }
  end

end
