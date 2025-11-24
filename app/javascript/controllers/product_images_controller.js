import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mainImage", 
    "thumbnail", 
    "tabButton", 
    "tabContent",
    "quantityInput",
    "addToCartForm"
  ]

  connect() {
    this.initializeTabs()
    this.initializeQuantityControls()
  }

  disconnect() {
    // Cleanup will be handled automatically by Stimulus
  }

  // Tab handling
  initializeTabs() {
    this.tabButtonTargets.forEach(button => {
      button.addEventListener('click', (e) => this.switchTab(e))
    })
  }

  switchTab(event) {
    const tabToShow = event.currentTarget.dataset.tab

    // Update button states
    this.tabButtonTargets.forEach(btn => {
      if (btn.dataset.tab === tabToShow) {
        btn.classList.add('border-indigo-500', 'text-indigo-600')
        btn.classList.remove('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      } else {
        btn.classList.remove('border-indigo-500', 'text-indigo-600')
        btn.classList.add('border-transparent', 'text-gray-500', 'hover:text-gray-700', 'hover:border-gray-300')
      }
    })

    // Show the selected tab content, hide others
    this.tabContentTargets.forEach(content => {
      content.classList.toggle('hidden', content.id !== `${tabToShow}-tab`)
    })
  }

  // Image gallery handling
  changeImage(event) {
    const thumbnail = event.currentTarget
    const imageUrl = thumbnail.dataset.imageUrl

    // Remove highlight from all thumbnails
    this.thumbnailTargets.forEach(thumb => {
      thumb.classList.remove('ring-2', 'ring-indigo-500')
    })

    // Add highlight to clicked thumbnail
    thumbnail.classList.add('ring-2', 'ring-indigo-500')

    // Update main image
    this.mainImageTarget.src = imageUrl
  }

  // Quantity controls
  initializeQuantityControls() {
    if (!this.hasQuantityInputTarget) return
  }

  decrease() {
    const currentValue = parseInt(this.quantityInputTarget.value)
    if (currentValue > 1) {
      this.quantityInputTarget.value = currentValue - 1
      this.updateCartFormQuantity()
    }
  }

  increase() {
    const currentValue = parseInt(this.quantityInputTarget.value)
    const max = parseInt(this.quantityInputTarget.getAttribute('max'))
    if (currentValue < max) {
      this.quantityInputTarget.value = currentValue + 1
      this.updateCartFormQuantity()
    }
  }

  updateCartFormQuantity() {
    if (!this.hasAddToCartFormTarget) return

    const quantityField = this.addToCartFormTarget.querySelector('input[name="quantity"]')
    if (quantityField) {
      quantityField.value = this.quantityInputTarget.value
    }
  }
}