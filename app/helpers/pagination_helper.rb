module PaginationHelper
  # Fallback pagination method in case Kaminari's page method isn't available
  def paginate_safely(collection, page = nil, per_page = 12)
    page = (page || 1).to_i
    per_page = per_page.to_i
    
    if collection.respond_to?(:page)
      # Use Kaminari if available
      collection.page(page).per(per_page)
    else
      # Manual pagination fallback
      offset = (page - 1) * per_page
      paginated = collection.limit(per_page).offset(offset)
      
      # Add pagination methods to the collection
      paginated.define_singleton_method(:current_page) { page }
      paginated.define_singleton_method(:total_pages) { (collection.count.to_f / per_page).ceil }
      paginated.define_singleton_method(:next_page) { page < paginated.total_pages ? page + 1 : nil }
      paginated.define_singleton_method(:prev_page) { page > 1 ? page - 1 : nil }
      
      paginated
    end
  end
end
