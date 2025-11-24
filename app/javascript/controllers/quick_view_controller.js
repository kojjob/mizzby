import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "content"]
  
  connect() {
    // Initialize the controller
    console.log("Quick view controller connected")
    
    // Close modal when clicking escape key
    document.addEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  disconnect() {
    // Clean up event listeners
    document.removeEventListener('keydown', this.handleKeyDown.bind(this))
  }
  
  handleKeyDown(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
  
  open(event) {
    // Get the product ID from the clicked element
    const productId = event.currentTarget.dataset.productId
    
    // Show the modal
    this.modalTarget.classList.remove('hidden')
    document.body.classList.add('overflow-hidden')
    
    // Load the product details
    this.loadProductDetails(productId)
  }
  
  close() {
    // Hide the modal
    this.modalTarget.classList.add('hidden')
    document.body.classList.remove('overflow-hidden')
    
    // Clear the content
    this.contentTarget.innerHTML = `
      <div class="p-8 flex justify-center items-center min-h-[50vh]">
        <div class="animate-pulse flex flex-col items-center">
          <div class="rounded-full bg-gray-200 h-16 w-16 mb-4 flex items-center justify-center">
            <svg class="animate-spin h-8 w-8 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
          </div>
          <p class="text-gray-500">Loading product details...</p>
        </div>
      </div>
    `
  }
  
  loadProductDetails(productId) {
    // Fetch the product details
    fetch(`/products/${productId}/quick_view`)
      .then(response => response.text())
      .then(html => {
        this.contentTarget.innerHTML = html
      })
      .catch(error => {
        console.error('Error loading product details:', error)
        this.contentTarget.innerHTML = `
          <div class="p-8 flex justify-center items-center min-h-[50vh]">
            <div class="flex flex-col items-center text-center">
              <div class="rounded-full bg-red-100 h-16 w-16 mb-4 flex items-center justify-center text-red-500">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 class="text-lg font-medium text-gray-900 mb-2">Error Loading Product</h3>
              <p class="text-gray-500 mb-4">There was an error loading the product details. Please try again later.</p>
              <button type="button" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors" data-action="click->quick-view#close">Close</button>
            </div>
          </div>
        `
      })
  }
}
