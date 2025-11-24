# Simple seed file to create 5 stores without dependencies

# Create 5 stores
5.times do |i|
  # Create a user for the store
  user = User.find_or_create_by(email: "store_owner#{i+1}@example.com") do |u|
    u.first_name = "Store"
    u.last_name = "Owner #{i+1}"
    u.password = "password123"
    u.password_confirmation = "password123"
  end

  # Create a seller for the user
  seller = Seller.find_or_create_by(user_id: user.id) do |s|
    s.business_name = "Store #{i+1}"
    s.description = "This is a description for Store #{i+1}"
    s.location = "Location #{i+1}"
    s.country = "Country #{i+1}"
    s.phone_number = "123-456-789#{i}"
    s.verified = true
    s.commission_rate = 10.0

    # Store-specific fields
    s.store_name = "Store #{i+1}"
    s.store_slug = "store-#{i+1}"
    s.store_settings = {
      enabled: true,
      logo: "https://via.placeholder.com/150",
      banner: "https://via.placeholder.com/1200x400",
      primary_color: "#4f46e5",
      secondary_color: "#818cf8"
    }
  end

  # Create a store for the seller
  store = Store.find_or_create_by(seller_id: seller.id) do |s|
    s.name = "Store #{i+1}"
    s.slug = "store-#{i+1}"
    s.description = "This is a description for Store #{i+1}"
  end

  puts "Created store: #{store.name}"
end

puts "Created 5 stores successfully!"
