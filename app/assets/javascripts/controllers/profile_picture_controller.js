// Profile picture controller
(function() {
  const application = window.Stimulus ? window.Stimulus.application : null;
  
  if (!application) {
    console.warn('Stimulus application not found for profile_picture_controller');
    return;
  }
  
  application.register('profile-picture', class extends window.Stimulus.Controller {
    static targets = ["preview", "input"];
    
    connect() {
      console.log("Profile picture controller connected");
    }
    
    preview() {
      const file = this.inputTarget.files[0];
      
      if (file) {
        // Make sure it's an image
        if (!file.type.match('image.*')) {
          console.error('Not an image file');
          return;
        }
        
        // Create file reader to read the file
        const reader = new FileReader();
        
        // Set up the reader to update the preview when loaded
        reader.onload = (e) => {
          this.previewTarget.src = e.target.result;
        };
        
        // Read the file
        reader.readAsDataURL(file);
      }
    }
    
    browse() {
      this.inputTarget.click();
    }
  });
})();
