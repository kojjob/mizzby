import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "progressBar"]

  connect() {
    // Initialize auto-dismiss for existing messages
    this.messageTargets.forEach(message => {
      if (message.dataset.autoDismiss === "true") {
        const dismissAfter = parseInt(message.dataset.dismissAfter) || 5000
        this.setupAutoDismiss(message, dismissAfter)
      }
    })
  }

  // Dismiss message when close button is clicked
  dismiss(event) {
    const message = event.currentTarget.closest('[data-flash-msg-target="message"]')
    this.removeMessage(message)
  }

  // Setup auto-dismiss with progress bar animation
  setupAutoDismiss(message, duration = 5000) {
    // Find the progress bar within this message
    const progressBar = message.querySelector('[data-flash-msg-target="progressBar"]')
    
    // Animate progress bar to shrink
    if (progressBar) {
      progressBar.style.transition = `transform ${duration}ms linear`
      
      // Small delay to ensure the transition starts after the element is rendered
      setTimeout(() => {
        progressBar.style.transform = 'scaleX(0)'
      }, 100)
    }
    
    // Set timeout to remove the message
    setTimeout(() => {
      this.removeMessage(message)
    }, duration)
  }

  // Smooth removal of message with animation
  removeMessage(message) {
    // First make it fade out and slide right
    message.classList.add('opacity-0')
    message.classList.add('translate-x-full')
    
    // After animation completes, remove from DOM
    message.addEventListener('transitionend', () => {
      message.remove()
    }, { once: true })
  }
  
  // Public method to show a new flash message programmatically
  showMessage(type, content) {
    // Get the appropriate template
    const templateId = `flash-template-${type}`
    const template = document.getElementById(templateId)
    
    if (!template) {
      console.error(`Flash message template not found: ${templateId}`)
      return
    }
    
    // Clone the template content
    const messageElement = template.content.cloneNode(true).firstElementChild
    
    // Set the message content
    const contentElement = messageElement.querySelector('.message-content')
    if (contentElement) {
      contentElement.textContent = content
    }
    
    // Add to the container
    this.element.prepend(messageElement)
    
    // Setup auto-dismiss
    if (messageElement.dataset.autoDismiss === "true") {
      const dismissAfter = parseInt(messageElement.dataset.dismissAfter) || 5000
      this.setupAutoDismiss(messageElement, dismissAfter)
    }
    
    // Add entrance animation
    messageElement.classList.add('animate-in')
    
    return messageElement
  }
  
  // Convenience methods for showing different types of messages
  showSuccess(content) {
    return this.showMessage('success', content)
  }
  
  showError(content) {
    return this.showMessage('error', content)
  }
  
  showInfo(content) {
    return this.showMessage('info', content)
  }
  
  showWarning(content) {
    return this.showMessage('warning', content)
  }
  
  // Method to pause progress bar when hovering over message
  pauseProgress(event) {
    const progressBar = event.currentTarget.querySelector('[data-flash-msg-target="progressBar"]')
    if (progressBar) {
      progressBar.style.animationPlayState = 'paused'
    }
  }
  
  // Method to resume progress bar when not hovering
  resumeProgress(event) {
    const progressBar = event.currentTarget.querySelector('[data-flash-msg-target="progressBar"]')
    if (progressBar) {
      progressBar.style.animationPlayState = 'running'
    }
  }
  
  // Clear all flash messages
  clearAll() {
    this.messageTargets.forEach(message => {
      this.removeMessage(message)
    })
  }
}