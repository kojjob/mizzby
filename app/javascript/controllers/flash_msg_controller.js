import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Called when controller is first connected to the DOM
  initialize() {
    // Store a reference to our clear function to use with Turbo navigation events
    this.clearAllMessages = this.clearAll.bind(this)
    
    // Listen for Turbo navigation to clear flash messages when navigating
    document.addEventListener("turbo:before-render", this.clearAllMessages)
  }
  
  // Clean up when controller is disconnected
  disconnect() {
    document.removeEventListener("turbo:before-render", this.clearAllMessages)
  }
  static targets = ["message", "progressBar"]

  connect() {
    // Initialize auto-dismiss for existing messages
    this.messageTargets.forEach(message => {
      if (message.dataset.autoDismiss === "true") {
        const dismissAfter = parseInt(message.dataset.dismissAfter) || 3000
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
  setupAutoDismiss(message, duration = 3000) {
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
    
    // Set timeout to remove the message and store the timeout ID
    const timeoutId = setTimeout(() => {
      this.removeMessage(message)
    }, duration);
    
    // Store timeout ID in dataset for later reference (used in hover pause)
    message.dataset.timeoutId = timeoutId;
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
    
    // Add mouse enter/leave handlers for pause/resume
    messageElement.setAttribute('data-action', 'mouseenter->flash-msg#pauseProgress mouseleave->flash-msg#resumeProgress')
    
    // Set the message content
    const contentElement = messageElement.querySelector('.message-content')
    if (contentElement) {
      contentElement.textContent = content
    }
    
    // Add to the container
    this.element.prepend(messageElement)
    
    // Setup auto-dismiss
    if (messageElement.dataset.autoDismiss === "true") {
      const dismissAfter = parseInt(messageElement.dataset.dismissAfter) || 3000
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
    // Stop the progress bar and clear the timeout
    const message = event.currentTarget;
    const progressBar = message.querySelector('[data-flash-msg-target="progressBar"]')
    
    if (progressBar) {
      // Save current transform state
      const currentTransform = getComputedStyle(progressBar).transform;
      // Stop the transition
      progressBar.style.transition = 'none';
      // Apply current state explicitly 
      progressBar.style.transform = currentTransform;
    }
    
    // Store the message element so we can reference it later
    this.hoveredMessage = message;
    
    // Clear existing timeout if it exists
    if (message.dataset.timeoutId) {
      clearTimeout(parseInt(message.dataset.timeoutId));
    }
  }
  
  // Method to resume progress bar when not hovering
  resumeProgress(event) {
    const message = event.currentTarget;
    const progressBar = message.querySelector('[data-flash-msg-target="progressBar"]')
    
    if (progressBar && this.hoveredMessage === message) {
      // Get remaining time based on progress
      const currentScale = this._getCurrentScaleX(progressBar);
      const dismissAfter = parseInt(message.dataset.dismissAfter) || 3000;
      const remainingTime = dismissAfter * currentScale;
      
      // Resume the transition for remaining time
      progressBar.style.transition = `transform ${remainingTime}ms linear`;
      progressBar.style.transform = 'scaleX(0)';
      
      // Set new timeout for dismissal
      const timeoutId = setTimeout(() => {
        this.removeMessage(message);
      }, remainingTime);
      
      // Store timeout ID in data attribute
      message.dataset.timeoutId = timeoutId;
    }
    
    this.hoveredMessage = null;
  }
  
  // Helper function to get current scaleX value from transform matrix
  _getCurrentScaleX(element) {
    const transform = getComputedStyle(element).transform;
    if (transform === 'none') return 1;
    
    const matrix = transform.match(/matrix\(([^\)]+)\)/);
    if (matrix && matrix[1]) {
      const values = matrix[1].split(', ');
      if (values.length >= 1) {
        return parseFloat(values[0]) || 0;
      }
    }
    return 0.5; // Fallback to half time if we can't determine
  }
  
  // Clear all flash messages
  clearAll() {
    // Check if messageTargets exists in case this is called during a turbo:before-render event
    if (this.hasOwnProperty('messageTargets')) {
      this.messageTargets.forEach(message => {
        // Clear any existing timeouts
        if (message.dataset.timeoutId) {
          clearTimeout(parseInt(message.dataset.timeoutId))
        }
        // Immediately remove from DOM without animation for page transitions
        message.remove()
      })
    }
  }
}