// Cart modal controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for cart_modal_controller');
    return;
  }
  
  application.register('cart-modal', class extends window.Stimulus.Controller {
    static targets = ["modal", "overlay"];
    
    connect() {
      console.log("Cart modal controller connected");
      
      // Add escape key listener
      this.escapeHandler = this.handleEscapeKey.bind(this);
      document.addEventListener('keydown', this.escapeHandler);
    }
    
    disconnect() {
      document.removeEventListener('keydown', this.escapeHandler);
    }
    
    handleEscapeKey(event) {
      if (event.key === 'Escape' && !this.modalTarget.classList.contains('hidden')) {
        this.close();
      }
    }
    
    open() {
      // Show modal
      this.modalTarget.classList.remove('hidden');
      this.overlayTarget.classList.remove('hidden');
      
      // Add animation classes
      setTimeout(() => {
        this.modalTarget.classList.add('opacity-100', 'translate-y-0');
        this.modalTarget.classList.remove('opacity-0', 'translate-y-4');
        this.overlayTarget.classList.add('opacity-50');
        this.overlayTarget.classList.remove('opacity-0');
      }, 10);
      
      // Prevent body scrolling
      document.body.classList.add('overflow-hidden');
    }
    
    close() {
      // Animate out
      this.modalTarget.classList.remove('opacity-100', 'translate-y-0');
      this.modalTarget.classList.add('opacity-0', 'translate-y-4');
      this.overlayTarget.classList.remove('opacity-50');
      this.overlayTarget.classList.add('opacity-0');
      
      // Hide after animation
      setTimeout(() => {
        this.modalTarget.classList.add('hidden');
        this.overlayTarget.classList.add('hidden');
        
        // Re-enable body scrolling
        document.body.classList.remove('overflow-hidden');
      }, 300);
    }
  });
})();
