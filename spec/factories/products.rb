FactoryBot.define do
  factory :product do
    association :category
    association :seller

    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 5) }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    discounted_price { nil }
    sku { Faker::Barcode.ean }
    barcode { Faker::Barcode.ean(8) }
    brand { Faker::Company.name }
    stock_quantity { rand(1..100) }
    condition { "new" }
    country_of_origin { "Ghana" }
    meta_title { name }
    meta_description { description }
    status { "active" }
    slug { name.parameterize }
    published { true }
    featured { false }
    is_digital { false }

    trait :on_sale do
      discounted_price { price * 0.8 }
      on_sale { true }
    end

    trait :featured do
      featured { true }
    end

    trait :digital do
      is_digital { true }
      stock_quantity { 9999 }
    end

    trait :out_of_stock do
      stock_quantity { 0 }
    end

    trait :unpublished do
      published { false }
      status { "inactive" }
    end
  end
end
