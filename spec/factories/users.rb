FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    confirmed_at { Time.current }
    admin { false }
    super_admin { false }
    active { true }

    trait :admin do
      admin { true }
    end

    trait :super_admin do
      super_admin { true }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_seller do
      after(:create) do |user|
        create(:seller, user: user)
      end
    end
  end
end
