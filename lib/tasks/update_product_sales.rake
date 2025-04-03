namespace :products do
  desc "Update on_sale flag for all products based on prices"
  task update_sale_status: :environment do
    puts "Updating on_sale status for all products..."
    
    # Count products before update
    total_products = Product.count
    current_on_sale = Product.where(on_sale: true).count
    
    # Update on_sale field for all products
    updated_count = Product.where('discounted_price IS NOT NULL AND discounted_price < price').update_all(on_sale: true)
    Product.where('discounted_price IS NULL OR discounted_price >= price').update_all(on_sale: false)
    
    # Count products after update
    new_on_sale = Product.where(on_sale: true).count
    
    puts "Completed!"
    puts "Total products: #{total_products}"
    puts "Products on sale before: #{current_on_sale}"
    puts "Products on sale after: #{new_on_sale}"
    puts "#{updated_count} products marked as on sale"
  end
end