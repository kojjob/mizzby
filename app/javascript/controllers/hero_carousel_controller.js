import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "slide", "indicator", "image"]
  static values = { 
    autoplay: Boolean,
    interval: Number,
    current: { type: Number, default: 0 }
  }

  connect() {
    this.initCarousel()
    
    // Start autoplay if enabled
    if (this.autoplayValue) {
      this.startAutoplay()
    }
  }
  
  disconnect() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
    }
  }
  
  initCarousel() {
    // Initial setup
    this.showSlide(this.currentValue)
    
    // Apply scaling effect to first image
    if (this.imageTargets.length > 0) {
      this.applyImageAnimation(this.imageTargets[this.currentValue])
    }
  }
  
  startAutoplay() {
    this.autoplayTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }
  
  resetAutoplay() {
    if (this.autoplayValue && this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
      this.startAutoplay()
    }
  }
  
  next() {
    const nextIndex = (this.currentValue + 1) % this.slideTargets.length
    this.showSlide(nextIndex)
  }
  
  prev() {
    const prevIndex = (this.currentValue - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showSlide(prevIndex)
  }
  
  goToSlide(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.showSlide(index)
    this.resetAutoplay()
  }
  
  showSlide(index) {
    // Hide all slides
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle('opacity-0', i !== index)
      slide.classList.toggle('opacity-100', i === index)
      
      // Reset animation for images
      if (this.imageTargets.length > i) {
        this.imageTargets[i].classList.remove('scale-110')
      }
    })
    
    // Update indicators
    this.indicatorTargets.forEach((indicator, i) => {
      indicator.classList.toggle('bg-white', i === index)
      indicator.classList.toggle('bg-white/50', i !== index)
    })
    
    // Apply scaling effect to current image
    if (this.imageTargets.length > index) {
      this.applyImageAnimation(this.imageTargets[index])
    }
    
    // Update current index
    this.currentValue = index
  }
  
  applyImageAnimation(image) {
    // Remove scale first to reset animation
    image.classList.remove('scale-105')
    
    // Force a reflow to make sure the removal takes effect
    void image.offsetWidth
    
    // Apply scale again to restart animation
    image.classList.add('scale-105')
  }
}