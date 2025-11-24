FactoryBot.define do
  factory :seller do
    association :user
    business_name { Faker::Company.name }
    description { Faker::Company.catch_phrase }
    location { Faker::Address.city }
    country { "Ghana" }
    phone_number { Faker::PhoneNumber.cell_phone }
    verified { false }
    commission_rate { 10.0 }
    acceptance_rate { 95.5 }
    average_response_time { 24 }
    store_name { Faker::Company.name }
    store_slug { store_name.parameterize }

    trait :verified do
      verified { true }
    end

    trait :with_custom_domain do
      custom_domain { "#{store_slug}.example.com" }
      domain_verified { true }
    end
  end
end
