# Create sample stores for testing

puts "Creating stores..."

# First, make sure we have some users
users = []
5.times do |i|
  email = "store_owner#{i+1}@example.com"
  user = User.find_or_initialize_by(email: email)
  
  if !user.persisted?
    user.first_name = Faker::Name.first_name
    user.last_name = Faker::Name.last_name
    user.password = 'password123'
    user.password_confirmation = 'password123'
    user.save(validate: false)
    puts "  Created user #{user.email}"
  end
  
  users << user
end

# Create sellers for these users
sellers = []
users.each_with_index do |user, i|
  seller = Seller.find_or_initialize_by(user_id: user.id)
  
  if !seller.persisted?
    seller.business_name = "#{Faker::Commerce.color.capitalize} #{Faker::Commerce.material.capitalize}"
    seller.description = Faker::Company.catch_phrase + ". " + Faker::Company.bs.capitalize + "."
    seller.location = Faker::Address.city
    seller.country = Faker::Address.country
    seller.phone_number = Faker::PhoneNumber.phone_number
    seller.verified = true
    seller.commission_rate = rand(5.0..15.0).round(2)
    
    # Store-specific fields
    seller.store_name = "#{seller.business_name} Store"
    seller.store_slug = "#{seller.business_name.parameterize}-store"
    seller.store_settings = {
      enabled: true,
      logo: "https://ui-avatars.com/api/?name=#{seller.business_name.gsub(' ', '+')}&background=random&color=fff&size=256",
      banner: "https://picsum.photos/seed/store#{i+1}/1200/400",
      primary_color: Faker::Color.hex_color,
      secondary_color: Faker::Color.hex_color
    }
    
    seller.save
    puts "  Created seller: #{seller.business_name}"
  end
  
  sellers << seller
end

# Create stores
stores = []
sellers.each do |seller|
  store = Store.find_or_initialize_by(seller_id: seller.id)
  
  if !store.persisted?
    store.name = seller.store_name
    store.slug = seller.store_slug
    store.description = seller.description
    store.save
    puts "  Created store: #{store.name}"
  end
  
  stores << store
end

puts "Created #{stores.count} stores successfully!"
