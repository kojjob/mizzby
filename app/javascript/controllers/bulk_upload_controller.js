import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["csvTab", "manualTab", "csvContent", "manualContent", "productRows", "rowTemplate", "fileInput", "dropzone", "fileName"]
  
  connect() {
    this.rowCount = 1
    console.log("BulkUpload controller connected")
  }
  
  showCsvTab(event) {
    event.preventDefault()
    
    // Update tab styles
    this.csvTabTarget.classList.add("border-indigo-500", "text-indigo-600")
    this.csvTabTarget.classList.remove("border-transparent", "text-gray-500")
    this.manualTabTarget.classList.remove("border-indigo-500", "text-indigo-600")
    this.manualTabTarget.classList.add("border-transparent", "text-gray-500")
    
    // Show/hide content
    this.csvContentTarget.classList.remove("hidden")
    this.manualContentTarget.classList.add("hidden")
  }
  
  showManualTab(event) {
    event.preventDefault()
    
    // Update tab styles
    this.manualTabTarget.classList.add("border-indigo-500", "text-indigo-600")
    this.manualTabTarget.classList.remove("border-transparent", "text-gray-500")
    this.csvTabTarget.classList.remove("border-indigo-500", "text-indigo-600")
    this.csvTabTarget.classList.add("border-transparent", "text-gray-500")
    
    // Show/hide content
    this.manualContentTarget.classList.remove("hidden")
    this.csvContentTarget.classList.add("hidden")
  }
  
  addRow(event) {
    event.preventDefault()
    this.rowCount++
    
    const template = this.rowTemplateTarget.innerHTML
    const newRow = template.replace(/INDEX/g, this.rowCount)
    
    // Create a temporary container to parse the HTML
    const temp = document.createElement('div')
    temp.innerHTML = newRow
    const rowElement = temp.firstElementChild
    
    this.productRowsTarget.appendChild(rowElement)
    
    // Animate in
    rowElement.style.opacity = '0'
    rowElement.style.transform = 'translateY(-10px)'
    setTimeout(() => {
      rowElement.style.transition = 'all 0.3s ease-out'
      rowElement.style.opacity = '1'
      rowElement.style.transform = 'translateY(0)'
    }, 10)
  }
  
  removeRow(event) {
    event.preventDefault()
    const row = event.target.closest('[data-product-row]')
    
    if (this.productRowsTarget.querySelectorAll('[data-product-row]').length > 1) {
      row.style.transition = 'all 0.3s ease-out'
      row.style.opacity = '0'
      row.style.transform = 'translateX(20px)'
      setTimeout(() => row.remove(), 300)
    } else {
      // Show a brief shake animation if trying to remove the last row
      row.classList.add('animate-shake')
      setTimeout(() => row.classList.remove('animate-shake'), 500)
    }
  }
  
  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.add('border-indigo-500', 'bg-indigo-50')
  }
  
  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove('border-indigo-500', 'bg-indigo-50')
  }
  
  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    this.dropzoneTarget.classList.remove('border-indigo-500', 'bg-indigo-50')
    
    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.fileInputTarget.files = files
      this.updateFileName(files[0].name)
    }
  }
  
  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      this.updateFileName(file.name)
    }
  }
  
  updateFileName(name) {
    if (this.hasFileNameTarget) {
      this.fileNameTarget.textContent = name
      this.fileNameTarget.classList.remove('hidden')
    }
  }
  
  triggerFileInput(event) {
    event.preventDefault()
    this.fileInputTarget.click()
  }
}
