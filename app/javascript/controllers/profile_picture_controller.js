import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['fileInput', 'preview', 'removeButton']

  connect() {
    // Optional: Any initialization logic
  }

  previewImage(event) {
    const input = event.target
    const file = input.files[0]
    
    if (file) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        this.previewTarget.innerHTML = `
          <img src="${e.target.result}" 
               class="w-full h-full object-cover rounded-full" 
               alt="Profile Preview">`
      }
      
      reader.readAsDataURL(file)
    }
  }

  removeProfilePicture() {
    // Set hidden input to trigger removal
    this.dispatch('remove-picture')
  }
}