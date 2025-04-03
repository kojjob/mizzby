# Create stores directly, bypassing associations

puts "Creating stores directly..."

# First, check if we have any existing sellers
existing_sellers = Seller.all
if existing_sellers.empty?
  puts "No existing sellers found. Creating a dummy seller first..."
  
  # Create a dummy user
  user = User.find_or_create_by(email: "dummy@example.com") do |u|
    u.first_name = "Dummy"
    u.last_name = "User"
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  # Create a dummy seller
  seller = Seller.create!(
    user: user,
    business_name: "Dummy Business",
    description: "This is a dummy seller for testing",
    location: "Test Location",
    country: "Test Country",
    phone_number: "123-456-7890",
    verified: true,
    commission_rate: 10.0,
    store_name: "Dummy Store",
    store_slug: "dummy-store",
    store_settings: {
      enabled: true
    }
  )
  
  puts "Created dummy seller: #{seller.business_name}"
  existing_sellers = [seller]
end

# Use the first seller for all stores
seller = existing_sellers.first
puts "Using seller: #{seller.business_name} (ID: #{seller.id})"

# Create 5 stores using the existing seller
5.times do |i|
  begin
    # Check if store already exists
    store_slug = "direct-store-#{i+1}"
    if Store.exists?(slug: store_slug)
      puts "  Store with slug '#{store_slug}' already exists, skipping..."
      next
    end
    
    # Create the store
    store = Store.new(
      seller_id: seller.id,
      name: "Direct Store #{i+1}",
      slug: store_slug,
      description: "This is a direct store #{i+1} created for testing"
    )
    
    # Save the store
    if store.save(validate: false)
      puts "  Created store: #{store.name} (ID: #{store.id})"
    else
      puts "  Failed to create store: #{store.errors.full_messages.join(', ')}"
    end
  rescue => e
    puts "  Error creating store #{i+1}: #{e.message}"
  end
end

puts "Created stores successfully!"
