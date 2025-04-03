# Create sample stores for testing

# First, make sure we have some sellers
if Seller.count < 5
  puts "Creating sellers for stores..."
  5.times do |i|
    # Create a user for the seller if needed
    unless User.exists?(email: "seller#{i+1}@example.com")
      user = User.create!(
        email: "seller#{i+1}@example.com",
        password: "password",
        password_confirmation: "password",
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        username: "seller#{i+1}",
        role: "seller"
      )
      puts "  Created user #{user.email}"
    else
      user = User.find_by(email: "seller#{i+1}@example.com")
    end
    
    # Create the seller if it doesn't exist
    unless user.seller.present?
      seller = Seller.create!(
        user: user,
        business_name: Faker::Company.name,
        description: Faker::Company.catch_phrase + ". " + Faker::Company.bs.capitalize + ".",
        location: Faker::Address.city,
        country: Faker::Address.country,
        phone_number: Faker::PhoneNumber.phone_number,
        verified: true,
        commission_rate: rand(5.0..15.0).round(2),
        store_name: "#{Faker::Commerce.color.capitalize} #{Faker::Commerce.material.capitalize} Store",
        store_slug: "#{Faker::Commerce.color.downcase}-#{Faker::Commerce.material.downcase}-store-#{i+1}",
        store_settings: {
          enabled: true,
          logo: "https://ui-avatars.com/api/?name=#{Faker::Commerce.color}+#{Faker::Commerce.material}&background=random&color=fff&size=256",
          banner: "https://picsum.photos/seed/store#{i+1}/1200/400",
          primary_color: Faker::Color.hex_color,
          secondary_color: Faker::Color.hex_color
        }
      )
      puts "  Created seller #{seller.business_name}"
    end
  end
end

# Now create stores for each seller
puts "Creating stores..."
Seller.all.each_with_index do |seller, index|
  # Skip if the seller already has a store
  next if Store.exists?(seller_id: seller.id)
  
  store = Store.create!(
    seller: seller,
    name: seller.store_name || "#{Faker::Commerce.color.capitalize} #{Faker::Commerce.material.capitalize} Store",
    slug: seller.store_slug || "#{Faker::Commerce.color.downcase}-#{Faker::Commerce.material.downcase}-store-#{index+1}",
    description: seller.description || Faker::Lorem.paragraph(sentence_count: 3)
  )
  
  # Create some store categories
  categories = []
  rand(3..5).times do |i|
    category = StoreCategory.create!(
      store: store,
      name: Faker::Commerce.department(max: 1),
      description: Faker::Lorem.sentence,
      position: i + 1
    )
    categories << category
  end
  
  # Create some store settings
  ["theme", "contact_email", "shipping_policy", "return_policy"].each do |key|
    StoreSetting.create!(
      store: store,
      key: key,
      value: case key
             when "theme"
               ["default", "modern", "classic", "minimal"].sample
             when "contact_email"
               seller.user.email
             when "shipping_policy"
               Faker::Lorem.paragraph(sentence_count: 3)
             when "return_policy"
               Faker::Lorem.paragraph(sentence_count: 3)
             end
    )
  end
  
  puts "  Created store: #{store.name} with #{categories.size} categories"
  
  # Create some products for this store if there aren't any
  if seller.products.count < 5
    puts "  Adding products to store..."
    
    5.times do |i|
      product = Product.create!(
        seller: seller,
        name: "#{Faker::Commerce.product_name} #{i+1}",
        description: Faker::Lorem.paragraph(sentence_count: 5),
        price: Faker::Commerce.price(range: 10..100.0),
        sku: "SKU-#{seller.id}-#{Time.now.to_i}-#{i}",
        stock_quantity: rand(1..100),
        published: true,
        featured: [true, false].sample,
        category_id: categories.sample.id,
        status: "active",
        slug: "#{Faker::Lorem.words(number: 3).join('-')}-#{Time.now.to_i}-#{i}"
      )
      puts "    Added product: #{product.name}"
    end
  end
end

puts "Finished creating stores and products!"
