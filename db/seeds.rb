# Digital Store Seeds
# This file populates the database with sample data for development and testing purposes

# Clear existing data (optional - comment out in production)
puts "Cleaning database..."
# Only use this in development, not in production!
if Rails.env.development?
  # Delete in the correct order to respect foreign key constraints
  Product.destroy_all
  # Delete categories in reverse order (children first, then parents)
  Category.where.not(parent_id: nil).destroy_all # Delete child categories first
  Category.where(parent_id: nil).destroy_all     # Then delete parent categories
  # Don't destroy users in case you have existing accounts
  # User.destroy_all
  # Seller.destroy_all
end

# Create admin user if it doesn't exist
puts "Creating admin user..."
admin_user = User.find_or_initialize_by(email: 'admin@example.com') do |user|
  user.first_name = 'Admin'
  user.last_name = 'User'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.admin = true
  user.confirmed_at = Time.current
end
admin_user.save(validate: false) unless admin_user.persisted?

# Create test user if it doesn't exist
puts "Creating test user..."
test_user = User.find_or_initialize_by(email: 'user@example.com') do |user|
  user.first_name = 'Test'
  user.last_name = 'User'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.confirmed_at = Time.current
end
test_user.save(validate: false) unless test_user.persisted?

# Create seller users
puts "Creating seller users..."
seller_users = []

3.times do |i|
  name = Faker::Name.unique.name.split(' ')
  email = "seller#{i+1}@example.com"

  user = User.find_or_initialize_by(email: email) do |u|
    u.first_name = name[0]
    u.last_name = name[1]
    u.password = 'password123'
    u.password_confirmation = 'password123'
    u.confirmed_at = Time.current
  end

  user.save(validate: false) unless user.persisted?
  seller_users << user
end

# Create sellers
puts "Creating sellers..."
sellers = []

seller_users.each_with_index do |user, i|
  business_name = ["Digital Dreams", "Code Crafters", "Pixel Perfect", "Tech Treasures"][i] || Faker::Company.unique.name

  seller = Seller.find_or_initialize_by(user: user) do |s|
    s.business_name = business_name
    s.description = Faker::Lorem.paragraph(sentence_count: 3)
    s.location = Faker::Address.city
    s.country = Faker::Address.country
    s.phone_number = Faker::PhoneNumber.phone_number
    s.verified = [true, false].sample
    s.commission_rate = rand(10.0..20.0).round(2)
    s.acceptance_rate = rand(90.0..100.0).round(2)
    s.average_response_time = rand(1..24)
  end

  seller.save unless seller.persisted?
  sellers << seller
end

# Create parent categories
puts "Creating categories..."
parent_categories = [
  {
    name: "Software & Applications",
    description: "Digital software and application solutions for various needs.",
    icon_name: "laptop-code",
    icon_color: "blue",
    children: [
      {
        name: "Desktop Software",
        description: "Applications designed for desktop computers.",
        icon_name: "desktop",
        icon_color: "teal"
      },
      {
        name: "Mobile Apps",
        description: "Applications designed for smartphones and tablets.",
        icon_name: "mobile-alt",
        icon_color: "indigo"
      },
      {
        name: "Web Applications",
        description: "Browser-based software solutions.",
        icon_name: "globe",
        icon_color: "purple"
      }
    ]
  },
  {
    name: "Digital Content",
    description: "Digital media and content for various purposes.",
    icon_name: "file-alt",
    icon_color: "green",
    children: [
      {
        name: "E-books & PDFs",
        description: "Digital books and documents.",
        icon_name: "book",
        icon_color: "red"
      },
      {
        name: "Templates & Designs",
        description: "Ready-to-use designs and templates.",
        icon_name: "palette",
        icon_color: "pink"
      },
      {
        name: "Stock Media",
        description: "Images, videos, and audio for commercial use.",
        icon_name: "photo-video",
        icon_color: "yellow"
      }
    ]
  },
  {
    name: "Courses & Education",
    description: "Digital learning resources and courses.",
    icon_name: "graduation-cap",
    icon_color: "orange",
    children: [
      {
        name: "Programming & Development",
        description: "Learn to code and develop software.",
        icon_name: "code",
        icon_color: "blue"
      },
      {
        name: "Business & Marketing",
        description: "Skills for business growth and marketing.",
        icon_name: "chart-line",
        icon_color: "green"
      },
      {
        name: "Design & Creativity",
        description: "Courses to enhance creative skills.",
        icon_name: "paint-brush",
        icon_color: "purple"
      }
    ]
  },
  {
    name: "Tools & Services",
    description: "Digital tools and online services.",
    icon_name: "tools",
    icon_color: "gray",
    children: [
      {
        name: "Plugins & Extensions",
        description: "Add-ons for existing software.",
        icon_name: "puzzle-piece",
        icon_color: "indigo"
      },
      {
        name: "API Services",
        description: "Application Programming Interfaces for integration.",
        icon_name: "network-wired",
        icon_color: "blue"
      },
      {
        name: "Data & Analytics",
        description: "Tools for data processing and analysis.",
        icon_name: "chart-bar",
        icon_color: "teal"
      }
    ]
  },
  {
    name: "Physical Products",
    description: "Tangible goods that will be shipped to you.",
    icon_name: "box",
    icon_color: "brown",
    children: [
      {
        name: "Tech Gadgets",
        description: "Latest technology and gadgets.",
        icon_name: "microchip",
        icon_color: "slate"
      },
      {
        name: "Books & Printed Media",
        description: "Physical books and printed content.",
        icon_name: "book-open",
        icon_color: "amber"
      },
      {
        name: "Merchandise",
        description: "Branded merchandise and products.",
        icon_name: "tshirt",
        icon_color: "rose"
      }
    ]
  }
]

# Create categories with their children
all_categories = []

parent_categories.each_with_index do |parent_data, position|
  slug = parent_data[:name].parameterize

  parent = Category.find_or_initialize_by(slug: slug)
  if !parent.persisted?
    parent.name = parent_data[:name]
    parent.description = parent_data[:description]
    parent.icon_name = parent_data[:icon_name]
    parent.icon_color = parent_data[:icon_color]
    parent.position = position
    parent.visible = true
    parent.save!
  end

  all_categories << parent

  parent_data[:children].each_with_index do |child_data, child_position|
    child_slug = child_data[:name].parameterize

    child = Category.find_or_initialize_by(slug: child_slug)
    if !child.persisted?
      child.name = child_data[:name]
      child.description = child_data[:description]
      child.icon_name = child_data[:icon_name]
      child.icon_color = child_data[:icon_color]
      child.position = child_position
      child.visible = true
      child.parent = parent
      child.save!
    end

    all_categories << child
  end
end

puts "Created #{all_categories.size} categories"

# Create products
puts "Creating products..."
products = []

# Method to create a product with consistent attributes
def create_product(attributes)
  # Generate a slug if not provided
  attributes[:slug] ||= attributes[:name].parameterize

  product = Product.find_or_initialize_by(sku: attributes[:sku])

  if !product.persisted?
    product.assign_attributes(attributes)
    product.save!

    # Optionally add some product images
    # This is a placeholder - in a real app you'd attach actual images
    if product.persisted? && Rails.env.development?
      # Simulate having product images
      # product.product_images.create(position: 0, alt_text: "Main product image")
    end
  end

  product
end

# Digital products
50.times do |i|
  # Choose a random subcategory (not a parent category)
  category = all_categories.select { |c| c.parent.present? }.sample
  seller = sellers.sample
  is_digital = category.parent.name != "Physical Products"

  # Generate a slug
  name = Faker::Commerce.unique.product_name

  # Set some products on sale
  on_sale = [true, false].sample
  price = rand(9.99..99.99).round(2)
  discounted_price = on_sale ? (price * rand(0.7..0.9)).round(2) : nil

  # Digital product-specific attributes
  if is_digital
    stock_quantity = nil # Digital products don't have stock
    weight = nil
    dimensions = nil

    # For courses or ebooks, add more detailed description
    if category.parent.name == "Courses & Education" || category.name == "E-books & PDFs"
      description = "# #{name}\n\n"
      description += "## Overview\n\n"
      description += Faker::Lorem.paragraph(sentence_count: 3) + "\n\n"
      description += "## Features\n\n"
      3.times do
        description += "* " + Faker::Lorem.sentence + "\n"
      end
      description += "\n## Requirements\n\n"
      2.times do
        description += "* " + Faker::Lorem.sentence + "\n"
      end
    else
      # Standard description for digital products
      description = Faker::Lorem.paragraph(sentence_count: 5)
    end
  else
    # Physical product attributes
    stock_quantity = rand(0..100)
    weight = rand(0.1..10.0).round(2)
    dimensions = "#{rand(1..30)}x#{rand(1..30)}x#{rand(1..30)} cm"
    description = Faker::Lorem.paragraph(sentence_count: 4)
  end

  # Create the product
  product_attributes = {
    name: name,
    description: description,
    price: price,
    discounted_price: discounted_price,
    stock_quantity: stock_quantity,
    sku: "PROD-#{i+1}-#{SecureRandom.hex(4)}",
    barcode: "BAR#{SecureRandom.hex(6)}",
    weight: weight,
    dimensions: dimensions,
    condition: "new",
    brand: Faker::Company.name,
    featured: [true, false].sample,
    currency: "USD",
    country_of_origin: Faker::Address.country,
    available_in_ghana: [true, false].sample,
    available_in_nigeria: [true, false].sample,
    shipping_time: is_digital ? nil : "#{rand(2..14)} business days",
    category: category,
    seller: seller,
    published: true,
    published_at: rand(1..60).days.ago,
    meta_title: name,
    meta_description: description.truncate(160),
    is_digital: is_digital,
    status: "active",
    slug: name.parameterize
  }

  product = create_product(product_attributes)
  products << product if product.persisted?
end

puts "Created #{products.size} products"
# Create stores
puts "Loading stores seed file..."
require_relative 'seeds/stores'

puts "Database seeding completed successfully!"
