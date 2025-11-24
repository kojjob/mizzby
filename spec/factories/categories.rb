FactoryBot.define do
  factory :category do
    name { Faker::Commerce.unique.department }
    description { Faker::Lorem.paragraph }
    slug { name.parameterize }
    visible { true }
    position { 1 }
    icon_name { "IconBox" }
    icon_color { "#3B82F6" }

    trait :with_parent do
      association :parent, factory: :category
    end

    trait :invisible do
      visible { false }
    end
  end
end
