FactoryBot.define do
  factory :review do
    association :user
    association :product

    rating { rand(1..5) }
    content { Faker::Lorem.paragraph(sentence_count: 3) }
    published { true }

    trait :unpublished do
      published { false }
    end

    trait :excellent do
      rating { 5 }
      content { "Excellent product! Highly recommend!" }
    end

    trait :poor do
      rating { 1 }
      content { "Very disappointed with this product." }
    end
  end
end
