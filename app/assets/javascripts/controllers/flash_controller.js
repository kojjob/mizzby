// Flash message controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for flash_controller');
    return;
  }
  
  application.register('flash', class extends window.Stimulus.Controller {
    static targets = ["message"];
    
    connect() {
      console.log("Flash controller connected");
      
      // Auto-dismiss after 5 seconds if not manually dismissed
      setTimeout(() => {
        this.dismiss();
      }, 5000);
    }
    
    dismiss() {
      // Animate out
      this.element.classList.add("opacity-0");
      
      // Remove from DOM after animation
      setTimeout(() => {
        this.element.remove();
      }, 300);
    }
  });
})();
