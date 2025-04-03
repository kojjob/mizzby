import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantity", "subtotal", "total", "form"]

  connect() {
    console.log("Cart controller connected")
  }

  updateQuantity(event) {
    // Prevent negative values
    if (event.target.value < 1) {
      event.target.value = 1
    }
    
    // Update display without page reload
    this.formTarget.requestSubmit()
  }
  
  // Add AJAX functionality for cart operations
  addToCart(event) {
    event.preventDefault()
    const form = event.target
    
    fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: {
        "Accept": "application/json"
      },
      credentials: "same-origin"
    })
    .then(response => response.json())
    .then(data => {
      // Update cart count in header
      const cartCount = document.querySelector(".cart-count")
      if (cartCount) {
        cartCount.textContent = data.cart_count
      }
      
      // Show success message
      alert(`${data.product_name} added to your cart`)
    })
    .catch(error => {
      console.error("Error adding to cart:", error)
    })
  }
}