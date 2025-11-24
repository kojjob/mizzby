FactoryBot.define do
  factory :order do
    association :user
    association :product

    total_amount { Faker::Commerce.price(range: 10.0..1000.0) }
    payment_id { SecureRandom.uuid }
    status { "pending" }
    payment_status { "pending" }
    payment_method { "credit_card" }
    payment_processor { "stripe" }

    trait :paid do
      status { "paid" }
      payment_status { "paid" }
    end

    trait :completed do
      status { "completed" }
      payment_status { "paid" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :refunded do
      status { "refunded" }
      payment_status { "refunded" }
    end
  end
end
