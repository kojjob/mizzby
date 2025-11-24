puts "Creating Categories..."

# Reset categories
Category.destroy_all

# Parent categories
digital_goods = Category.create!(
  name: "Digital Goods",
  description: "Digital products and downloads",
  slug: "digital-goods",
  visible: true,
  icon_name: "cloud-download",
  icon_color: "blue"
)

software = Category.create!(
  name: "Software",
  description: "Applications, scripts, and plugins",
  slug: "software",
  parent: digital_goods,
  visible: true,
  icon_name: "code",
  icon_color: "indigo"
)

courses = Category.create!(
  name: "Online Courses",
  description: "Educational courses and tutorials",
  slug: "online-courses",
  parent: digital_goods,
  visible: true,
  icon_name: "academic-cap",
  icon_color: "green"
)

ebooks = Category.create!(
  name: "E-books",
  description: "Digital books and publications",
  slug: "ebooks",
  parent: digital_goods,
  visible: true,
  icon_name: "book-open",
  icon_color: "amber"
)

graphics = Category.create!(
  name: "Graphics & Design",
  description: "Templates, graphics, and design assets",
  slug: "graphics-design",
  parent: digital_goods,
  visible: true,
  icon_name: "photograph",
  icon_color: "rose"
)

physical_goods = Category.create!(
  name: "Physical Products",
  description: "Tangible goods that require shipping",
  slug: "physical-products",
  visible: true,
  icon_name: "shopping-bag",
  icon_color: "purple"
)

electronics = Category.create!(
  name: "Electronics",
  description: "Electronic devices and accessories",
  slug: "electronics",
  parent: physical_goods,
  visible: true,
  icon_name: "device-mobile",
  icon_color: "gray"
)

# Software subcategories
Category.create!(
  name: "Mobile Apps",
  description: "Applications for smartphones and tablets",
  slug: "mobile-apps",
  parent: software,
  visible: true,
  icon_name: "device-mobile",
  icon_color: "teal"
)

Category.create!(
  name: "Desktop Software",
  description: "Applications for desktop computers",
  slug: "desktop-software",
  parent: software,
  visible: true,
  icon_name: "desktop-computer",
  icon_color: "indigo"
)

Category.create!(
  name: "Plugins & Extensions",
  description: "Add-ons for existing software platforms",
  slug: "plugins-extensions",
  parent: software,
  visible: true,
  icon_name: "puzzle",
  icon_color: "blue"
)

Category.create!(
  name: "Scripts & Code",
  description: "Programming scripts and code snippets",
  slug: "scripts-code",
  parent: software,
  visible: true,
  icon_name: "code",
  icon_color: "indigo"
)

# Course subcategories
Category.create!(
  name: "Programming",
  description: "Learn programming and development",
  slug: "programming-courses",
  parent: courses,
  visible: true,
  icon_name: "code",
  icon_color: "blue"
)

Category.create!(
  name: "Business",
  description: "Business and entrepreneurship courses",
  slug: "business-courses",
  parent: courses,
  visible: true,
  icon_name: "briefcase",
  icon_color: "gray"
)

Category.create!(
  name: "Design",
  description: "Design and creative arts courses",
  slug: "design-courses",
  parent: courses,
  visible: true,
  icon_name: "color-swatch",
  icon_color: "rose"
)

Category.create!(
  name: "Personal Development",
  description: "Self-improvement and personal growth",
  slug: "personal-development-courses",
  parent: courses,
  visible: true,
  icon_name: "sparkles",
  icon_color: "amber"
)

# E-book subcategories
Category.create!(
  name: "Fiction",
  description: "Novels, short stories, and fiction e-books",
  slug: "fiction-ebooks",
  parent: ebooks,
  visible: true,
  icon_name: "book-open",
  icon_color: "amber"
)

Category.create!(
  name: "Non-Fiction",
  description: "Non-fiction and educational e-books",
  slug: "non-fiction-ebooks",
  parent: ebooks,
  visible: true,
  icon_name: "academic-cap",
  icon_color: "green"
)

Category.create!(
  name: "Guides & Tutorials",
  description: "How-to guides and tutorial e-books",
  slug: "guides-tutorials",
  parent: ebooks,
  visible: true,
  icon_name: "document-text",
  icon_color: "blue"
)

# Graphics subcategories
Category.create!(
  name: "Templates",
  description: "Ready-to-use design templates",
  slug: "templates",
  parent: graphics,
  visible: true,
  icon_name: "template",
  icon_color: "indigo"
)

Category.create!(
  name: "Stock Photos",
  description: "Professional stock photography",
  slug: "stock-photos",
  parent: graphics,
  visible: true,
  icon_name: "photograph",
  icon_color: "rose"
)

Category.create!(
  name: "Graphics & Illustrations",
  description: "Digital art, illustrations, and graphic elements",
  slug: "graphics-illustrations",
  parent: graphics,
  visible: true,
  icon_name: "color-swatch",
  icon_color: "purple"
)

Category.create!(
  name: "UI Kits",
  description: "User interface design kits and elements",
  slug: "ui-kits",
  parent: graphics,
  visible: true,
  icon_name: "view-grid",
  icon_color: "blue"
)

# Electronics subcategories
Category.create!(
  name: "Smartphones & Accessories",
  description: "Mobile phones and related accessories",
  slug: "smartphones-accessories",
  parent: electronics,
  visible: true,
  icon_name: "device-mobile",
  icon_color: "gray"
)

Category.create!(
  name: "Computers & Laptops",
  description: "Desktop computers and laptops",
  slug: "computers-laptops",
  parent: electronics,
  visible: true,
  icon_name: "desktop-computer",
  icon_color: "gray"
)

Category.create!(
  name: "Audio & Headphones",
  description: "Audio equipment and headphones",
  slug: "audio-headphones",
  parent: electronics,
  visible: true,
  icon_name: "music-note",
  icon_color: "gray"
)

puts "Created #{Category.count} categories"
