// Unified dropdown controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for dropdown_controller');
    return;
  }
  
  application.register('dropdown', class extends window.Stimulus.Controller {
    static targets = ["button", "menu", "arrow"];
    
    connect() {
      // Add outside click handler
      this.outsideClickHandler = this.hide.bind(this);
      document.addEventListener("click", this.outsideClickHandler);
      console.log("Dropdown controller connected");
    }
    
    disconnect() {
      // Clean up event listeners
      document.removeEventListener("click", this.outsideClickHandler);
    }
    
    toggle(event) {
      if (event) {
        event.stopPropagation();
      }
      
      if (this.isOpen()) {
        this.hide();
      } else {
        this.show();
      }
    }
    
    show() {
      // Close all other dropdowns first
      document.querySelectorAll("[data-dropdown-menu], [data-dropdown-target='menu']").forEach(menu => {
        if (menu !== this.menuTarget) {
          menu.classList.add("hidden");
        }
      });
      
      // Now show this dropdown
      this.menuTarget.classList.remove("hidden");
      
      // Rotate arrow if it exists
      if (this.hasArrowTarget) {
        this.arrowTarget.classList.add("transform", "rotate-180");
      }
    }
    
    hide(event) {
      // Don't hide if the click was inside this controller element
      if (event && this.element.contains(event.target) && event.target !== document) {
        return;
      }
      
      this.menuTarget.classList.add("hidden");
      
      // Reset arrow rotation
      if (this.hasArrowTarget) {
        this.arrowTarget.classList.remove("transform", "rotate-180");
      }
    }
    
    isOpen() {
      return !this.menuTarget.classList.contains("hidden");
    }
  });
})();
