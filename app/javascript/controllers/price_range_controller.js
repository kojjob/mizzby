import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minInput", "maxInput", "minThumb", "maxThumb", "minValue", "maxValue", "track", "minHiddenInput", "maxHiddenInput"]
  static values = {
    min: Number,
    max: Number,
    currentMin: Number,
    currentMax: Number
  }
  
  connect() {
    // Initialize values
    this.minInputTarget.value = this.currentMinValue
    this.maxInputTarget.value = this.currentMaxValue
    
    // Set initial positions
    this.updateMinThumb()
    this.updateMaxThumb()
    this.updateTrack()
    this.updateValues()
    
    // Set hidden inputs for form submission
    this.minHiddenInputTarget.value = this.currentMinValue
    this.maxHiddenInputTarget.value = this.currentMaxValue
  }
  
  updateMinThumb() {
    const percent = ((this.minInputTarget.value - this.minValue) / (this.maxValue - this.minValue)) * 100
    this.minThumbTarget.style.left = `${percent}%`
    this.currentMinValue = parseInt(this.minInputTarget.value)
    this.minHiddenInputTarget.value = this.currentMinValue
    this.updateTrack()
    this.updateValues()
  }
  
  updateMaxThumb() {
    const percent = ((this.maxInputTarget.value - this.minValue) / (this.maxValue - this.minValue)) * 100
    this.maxThumbTarget.style.left = `${percent}%`
    this.currentMaxValue = parseInt(this.maxInputTarget.value)
    this.maxHiddenInputTarget.value = this.currentMaxValue
    this.updateTrack()
    this.updateValues()
  }
  
  updateTrack() {
    const minPercent = ((this.minInputTarget.value - this.minValue) / (this.maxValue - this.minValue)) * 100
    const maxPercent = ((this.maxInputTarget.value - this.minValue) / (this.maxValue - this.minValue)) * 100
    
    this.trackTarget.style.left = `${minPercent}%`
    this.trackTarget.style.width = `${maxPercent - minPercent}%`
  }
  
  updateValues() {
    this.minValueTarget.textContent = `$${this.minInputTarget.value}`
    this.maxValueTarget.textContent = `$${this.maxInputTarget.value}`
  }
  
  formSubmit(event) {
    // Submit form when slider value has been set
    event.target.requestSubmit()
  }
}