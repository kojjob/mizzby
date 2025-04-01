// Example of how to use flash messages programmatically from JavaScript
// This is an example file only - not for production use

document.addEventListener('DOMContentLoaded', () => {
  // Example: Show success message after form submission
  document.querySelector('form.example-form')?.addEventListener('submit', (event) => {
    event.preventDefault();
    
    // Get the flash controller from the container
    const flashController = document.getElementById('flash-container')?.
      closest('[data-controller="flash-msg"]')?.
      stimulus_controller;
    
    if (flashController) {
      // Show success message
      flashController.showSuccess('Form submitted successfully!');
    }
  });
  
  // Example: Show error message when an AJAX request fails
  async function fetchData() {
    try {
      const response = await fetch('/api/example');
      if (!response.ok) throw new Error('Network response was not ok');
      return await response.json();
    } catch (error) {
      const flashController = document.getElementById('flash-container')?.
        closest('[data-controller="flash-msg"]')?.
        stimulus_controller;
      
      if (flashController) {
        flashController.showError('Failed to fetch data. Please try again later.');
      }
      
      console.error('Error:', error);
    }
  }
  
  // Example: Show info message as a notification
  document.querySelector('.show-info-example')?.addEventListener('click', () => {
    const flashController = document.getElementById('flash-container')?.
      closest('[data-controller="flash-msg"]')?.
      stimulus_controller;
    
    if (flashController) {
      flashController.showInfo('This is an information message that can be used for notifications.');
    }
  });
  
  // Example: Show warning message
  document.querySelector('.show-warning-example')?.addEventListener('click', () => {
    const flashController = document.getElementById('flash-container')?.
      closest('[data-controller="flash-msg"]')?.
      stimulus_controller;
    
    if (flashController) {
      flashController.showWarning('Warning: This action cannot be undone.');
    }
  });
});

/*
  Usage in Rails views or other JS files:
  
  // To show a success message
  document.getElementById('flash-container').closest('[data-controller="flash-msg"]')
    .stimulus_controller.showSuccess('Your changes have been saved');
  
  // To show an error message
  document.getElementById('flash-container').closest('[data-controller="flash-msg"]')
    .stimulus_controller.showError('Something went wrong');
  
  // To show an info message
  document.getElementById('flash-container').closest('[data-controller="flash-msg"]')
    .stimulus_controller.showInfo('You have 3 unread messages');
  
  // To show a warning message
  document.getElementById('flash-container').closest('[data-controller="flash-msg"]')
    .stimulus_controller.showWarning('Your session will expire in 5 minutes');
  
  // To clear all flash messages
  document.getElementById('flash-container').closest('[data-controller="flash-msg"]')
    .stimulus_controller.clearAll();
*/