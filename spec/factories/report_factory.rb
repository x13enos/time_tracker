FactoryBot.define do

  factory :report do
    association :user

    uuid     { SecureRandom.uuid }
    file     { fixture_file_upload("#{Rails.root}/spec/support/files/sample.pdf") }
  end

end
