import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "zone", "text"]
  
  connect() {
    this.setupDragAndDrop()
  }
  
  setupDragAndDrop() {
    const zone = this.zoneTarget
    
    ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      zone.addEventListener(eventName, this.preventDefaults.bind(this), false)
    })
    
    ;['dragenter', 'dragover'].forEach(eventName => {
      zone.addEventListener(eventName, this.highlight.bind(this), false)
    })
    
    ;['dragleave', 'drop'].forEach(eventName => {
      zone.addEventListener(eventName, this.unhighlight.bind(this), false)
    })
    
    zone.addEventListener('drop', this.handleDrop.bind(this), false)
  }
  
  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }
  
  highlight() {
    this.zoneTarget.classList.add('border-indigo-400', 'bg-indigo-50/50')
    this.zoneTarget.classList.remove('border-gray-200')
  }
  
  unhighlight() {
    this.zoneTarget.classList.remove('border-indigo-400', 'bg-indigo-50/50')
    this.zoneTarget.classList.add('border-gray-200')
  }
  
  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files
    
    if (files.length > 0) {
      this.inputTarget.files = files
      this.updateDisplay(files[0])
    }
  }
  
  handleChange(event) {
    const file = event.target.files[0]
    if (file) {
      this.updateDisplay(file)
    }
  }
  
  updateDisplay(file) {
    const fileName = file.name
    const fileSize = this.formatFileSize(file.size)
    
    this.textTarget.innerHTML = `
      <div class="flex items-center gap-3 justify-center">
        <svg class="w-8 h-8 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
        </svg>
        <div class="text-left">
          <p class="font-semibold text-indigo-600">${fileName}</p>
          <p class="text-sm text-gray-500">${fileSize}</p>
        </div>
      </div>
    `
    
    this.zoneTarget.classList.add('border-indigo-400', 'bg-indigo-50/30')
    this.zoneTarget.classList.remove('border-gray-200')
  }
  
  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }
}
