FactoryBot.define do
  factory :vote do
    association :user
    country_code { Faker::Address.country_code }
  end
end
