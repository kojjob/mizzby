# Minimal seed file to create 5 stores without any dependencies

puts "Creating 5 minimal stores..."

# Create 5 stores directly
5.times do |i|
  # Create a user for the store
  user = User.find_or_initialize_by(email: "store_owner#{i+1}@example.com")
  if !user.persisted?
    user.assign_attributes(
      first_name: "Store",
      last_name: "Owner #{i+1}",
      password: "password123",
      password_confirmation: "password123"
    )
    user.save(validate: false)
    puts "  Created user #{user.email}"
  end
  
  # Create a seller for the user
  seller = Seller.find_or_initialize_by(user_id: user.id)
  if !seller.persisted?
    seller.assign_attributes(
      business_name: "Store #{i+1}",
      description: "This is a description for Store #{i+1}",
      location: "Location #{i+1}",
      country: "Country #{i+1}",
      phone_number: "123-456-789#{i}",
      verified: true,
      commission_rate: 10.0,
      store_name: "Store #{i+1}",
      store_slug: "store-#{i+1}",
      store_settings: {
        enabled: true,
        logo: "https://via.placeholder.com/150",
        banner: "https://via.placeholder.com/1200x400",
        primary_color: "#4f46e5",
        secondary_color: "#818cf8"
      }
    )
    seller.save(validate: false)
    puts "  Created seller #{seller.business_name}"
  end
  
  # Create a store for the seller
  store = Store.find_or_initialize_by(seller_id: seller.id)
  if !store.persisted?
    store.assign_attributes(
      name: "Store #{i+1}",
      slug: "store-#{i+1}",
      description: "This is a description for Store #{i+1}"
    )
    store.save(validate: false)
    puts "  Created store: #{store.name}"
  end
end

puts "Created 5 minimal stores successfully!"
