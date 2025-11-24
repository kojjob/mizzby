import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { id: Number }

  remove(event) {
    // Optional: Add any client-side removal logic
    const item = this.element.closest('.cart-item')
    if (item) {
      item.classList.add('fade-out')
      setTimeout(() => {
        item.remove()
      }, 300) // Adjust the timeout to match your CSS transition duration
    }
    // You can also prevent the default action if needed
    event.preventDefault()
    // If you want to prevent the default action of the link/button
     event.stopPropagation()
     event.stopImmediatePropagation()
    // Or handle any other logic before the request is sent

    // Trigger the Turbo Frame update
    const url = `/cart_items/${this.idValue}`
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({ id: this.idValue })
    })
      .then(response => {
        if (response.ok) {
          return response.text()
        } else {
          throw new Error('Network response was not ok')
        }
      })
      .then(html => {
        // Turbo will handle the response and update the DOM
        Turbo.renderStreamMessage(html)
      })
      .catch(error => {
        console.error('Error:', error)
      })  

    // For example, if you want to replace the entire cart item list:
    Turbo.visit('/cart_items', { action: 'replace' })
    // Or if you want to append a new item:
    Turbo.visit('/cart_items', { action: 'append' })
    // Or if you want to remove the item from the DOM
    item = this.element.closest('.cart-item')
  }

  update(event) {
    // Optional: Add any client-side update logic
    const item = this.element.closest('.cart-item')
    if (item) {
      item.classList.add('fade-out')
      setTimeout(() => {
        item.remove()
      }, 300) // Adjust the timeout to match your CSS transition duration
    }
 
     event.preventDefault()
     event.stopPropagation()
     event.stopImmediatePropagation()
    // Or handle any other logic before the request is sent
    const url = `/cart_items/${this.idValue}`
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({ id: this.idValue })
    })
      .then(response => {
        if (response.ok) {
          return response.text()
        } else {
          throw new Error('Network response was not ok')
        }
      })
      .then(html => {
        // Turbo will handle the response and update the DOM
        Turbo.renderStreamMessage(html)
      })
      .catch(error => {
        console.error('Error:', error)
      })
      
    // For example, if you want to replace the entire cart item list:
    Turbo.visit('/cart_items', { action: 'replace' })
    // Or if you want to append a new item:
    Turbo.visit('/cart_items', { action: 'append' })
    // Or if you want to remove the item from the DOM
    item.remove()

  }
}