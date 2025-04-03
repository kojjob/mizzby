import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  
  connect() {
    this.loadPreview()
  }
  
  loadPreview() {
    const theme = this.element.value
    
    fetch(`/sellers/store/theme_preview?theme=${theme}`)
      .then(response => response.text())
      .then(html => {
        this.containerTarget.innerHTML = html
      })
  }
  
  // Called when the select changes
  change(event) {
    this.loadPreview()
  }
}