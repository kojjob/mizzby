// Cart dropdown controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for cart_dropdown_controller');
    return;
  }
  
  application.register('cart-dropdown', class extends window.Stimulus.Controller {
    static targets = ["dropdown"];
    
    connect() {
      console.log("Cart dropdown controller connected");
      
      // Add outside click handler
      this.outsideClickHandler = this.hide.bind(this);
      document.addEventListener('click', this.outsideClickHandler);
    }
    
    disconnect() {
      document.removeEventListener('click', this.outsideClickHandler);
    }
    
    toggle(event) {
      if (event) {
        event.stopPropagation();
      }
      
      const isVisible = !this.dropdownTarget.classList.contains('hidden');
      
      if (isVisible) {
        this.hide();
      } else {
        this.show();
      }
    }
    
    show() {
      // Show dropdown
      this.dropdownTarget.classList.remove('hidden');
      
      // Add animation classes
      setTimeout(() => {
        this.dropdownTarget.classList.add('opacity-100', 'translate-y-0');
        this.dropdownTarget.classList.remove('opacity-0', 'translate-y-1');
      }, 10);
    }
    
    hide(event) {
      // Don't hide if clicked within the dropdown
      if (event && this.element.contains(event.target)) {
        return;
      }
      
      // Hide with animation
      this.dropdownTarget.classList.remove('opacity-100', 'translate-y-0');
      this.dropdownTarget.classList.add('opacity-0', 'translate-y-1');
      
      // Remove from DOM after animation
      setTimeout(() => {
        this.dropdownTarget.classList.add('hidden');
      }, 300);
    }
  });
})();
