import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "product", "fields", "chevron"]
  
  connect() {
    this.productCount = this.productTargets.length
    console.log("BulkProducts controller connected with", this.productCount, "products")
  }
  
  toggleProduct(event) {
    const card = event.target.closest('[data-bulk-products-target="product"]')
    const fields = card.querySelector('[data-bulk-products-target="fields"]')
    const chevron = card.querySelector('[data-bulk-products-target="chevron"]')
    
    if (fields && chevron) {
      fields.classList.toggle('hidden')
      chevron.classList.toggle('rotate-180')
    }
  }
  
  addProduct(event) {
    event.preventDefault()
    this.productCount++
    
    const template = this.buildProductTemplate(this.productCount)
    const temp = document.createElement('div')
    temp.innerHTML = template
    const newProduct = temp.firstElementChild
    
    this.containerTarget.appendChild(newProduct)
    
    // Animate in
    newProduct.style.opacity = '0'
    newProduct.style.transform = 'translateY(-20px)'
    setTimeout(() => {
      newProduct.style.transition = 'all 0.4s ease-out'
      newProduct.style.opacity = '1'
      newProduct.style.transform = 'translateY(0)'
    }, 10)
    
    // Scroll to new product
    setTimeout(() => {
      newProduct.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }, 100)
  }
  
  removeProduct(event) {
    event.preventDefault()
    const card = event.target.closest('[data-bulk-products-target="product"]')
    
    if (this.productTargets.length > 1) {
      card.style.transition = 'all 0.3s ease-out'
      card.style.opacity = '0'
      card.style.transform = 'translateX(30px)'
      card.style.height = card.offsetHeight + 'px'
      
      setTimeout(() => {
        card.style.height = '0'
        card.style.marginBottom = '0'
        card.style.padding = '0'
      }, 200)
      
      setTimeout(() => card.remove(), 400)
    }
  }
  
  buildProductTemplate(index) {
    return `
      <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden product-card" data-bulk-products-target="product">
        <div class="px-6 py-4 bg-gradient-to-r from-gray-50 to-white border-b border-gray-100 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <span class="w-8 h-8 rounded-full bg-gradient-to-br from-indigo-500 to-purple-500 flex items-center justify-center text-white font-bold text-sm">
              ${index}
            </span>
            <h3 class="font-semibold text-gray-900">Product ${index}</h3>
          </div>
          <div class="flex items-center gap-2">
            <button type="button" 
                    data-action="click->bulk-products#removeProduct"
                    class="p-2 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
              </svg>
            </button>
            <button type="button" 
                    data-action="click->bulk-products#toggleProduct"
                    class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors">
              <svg class="w-5 h-5 transform transition-transform" data-bulk-products-target="chevron" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
              </svg>
            </button>
          </div>
        </div>
        
        <div class="p-6 space-y-6" data-bulk-products-target="fields">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Product Name <span class="text-red-500">*</span>
              </label>
              <input type="text" 
                     name="products[${index}][name]" 
                     placeholder="Enter product name"
                     class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Category <span class="text-red-500">*</span>
              </label>
              <select name="products[${index}][category_id]" 
                      class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 bg-white">
                <option value="">Select category</option>
              </select>
            </div>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Description <span class="text-red-500">*</span>
            </label>
            <textarea name="products[${index}][description]" 
                      rows="3" 
                      placeholder="Describe your product..."
                      class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 resize-none"></textarea>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Price <span class="text-red-500">*</span>
              </label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 font-medium">$</span>
                <input type="number" 
                       name="products[${index}][price]" 
                       step="0.01" 
                       min="0"
                       placeholder="0.00"
                       class="w-full pl-8 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Sale Price
              </label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 font-medium">$</span>
                <input type="number" 
                       name="products[${index}][discounted_price]" 
                       step="0.01" 
                       min="0"
                       placeholder="0.00"
                       class="w-full pl-8 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
              </div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Stock Quantity
              </label>
              <input type="number" 
                     name="products[${index}][stock_quantity]" 
                     min="0"
                     value="0"
                     class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
            </div>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Brand <span class="text-red-500">*</span>
              </label>
              <input type="text" 
                     name="products[${index}][brand]" 
                     placeholder="Brand name"
                     class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                SKU
              </label>
              <input type="text" 
                     name="products[${index}][sku]" 
                     placeholder="Auto-generated"
                     class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Condition
              </label>
              <select name="products[${index}][condition]" 
                      class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 bg-white">
                <option value="new" selected>New</option>
                <option value="refurbished">Refurbished</option>
                <option value="used">Used</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    `
  }
}
