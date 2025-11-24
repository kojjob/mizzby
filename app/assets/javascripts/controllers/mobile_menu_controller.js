// Mobile menu controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for mobile_menu_controller');
    return;
  }
  
  application.register('mobile-menu', class extends window.Stimulus.Controller {
    static targets = ["menu", "openIcon", "closeIcon"];
    
    connect() {
      console.log("Mobile menu controller connected");
    }
    
    toggle(event) {
      if (event) {
        event.preventDefault();
      }
      
      if (this.isOpen()) {
        this.hide();
      } else {
        this.show();
      }
    }
    
    show() {
      // Show the menu
      this.menuTarget.classList.remove("hidden");
      
      // Toggle icons if they exist
      if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
        this.openIconTarget.classList.add("hidden");
        this.closeIconTarget.classList.remove("hidden");
      }
      
      // Disable body scrolling on mobile
      document.body.classList.add("overflow-hidden", "md:overflow-auto");
    }
    
    hide() {
      // Hide the menu
      this.menuTarget.classList.add("hidden");
      
      // Toggle icons if they exist
      if (this.hasOpenIconTarget && this.hasCloseIconTarget) {
        this.openIconTarget.classList.remove("hidden");
        this.closeIconTarget.classList.add("hidden");
      }
      
      // Re-enable body scrolling
      document.body.classList.remove("overflow-hidden", "md:overflow-auto");
    }
    
    isOpen() {
      return !this.menuTarget.classList.contains("hidden");
    }
  });
})();
