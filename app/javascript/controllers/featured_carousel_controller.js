import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "track"]

  connect() {
    this.itemWidth = 288 // w-72 (width) in pixels
    this.gap = 16 // gap-4 (margin) in pixels
    this.currentIndex = 0
    this.resizeObserver = new ResizeObserver(entries => this.handleResize())
    this.resizeObserver.observe(this.containerTarget)

    // Setup touch events for mobile swipe
    this.touchStartX = 0
    this.touchEndX = 0

    this.containerTarget.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: true })
    this.containerTarget.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: true })

    // Add mouse drag support
    this.containerTarget.addEventListener('mousedown', this.handleMouseDown.bind(this))

    this.handleResize()
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }

    // Remove event listeners
    this.containerTarget.removeEventListener('touchstart', this.handleTouchStart.bind(this))
    this.containerTarget.removeEventListener('touchend', this.handleTouchEnd.bind(this))
    this.containerTarget.removeEventListener('mousedown', this.handleMouseDown.bind(this))
    document.removeEventListener('mousemove', this.handleMouseMove.bind(this))
    document.removeEventListener('mouseup', this.handleMouseUp.bind(this))
  }

  handleResize() {
    // Calculate visible items based on container width
    const containerWidth = this.containerTarget.offsetWidth
    this.visibleItems = Math.floor(containerWidth / (this.itemWidth + this.gap))
    this.maxIndex = Math.max(0, this.trackTarget.children.length - this.visibleItems)

    // Ensure current index is valid
    if (this.currentIndex > this.maxIndex) {
      this.currentIndex = this.maxIndex
      this.updatePosition()
    }
  }

  next() {
    if (this.currentIndex < this.maxIndex) {
      this.currentIndex++
      this.updatePosition()
    } else {
      // Optional: loop back to start
      this.currentIndex = 0
      this.updatePosition()
    }
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.updatePosition()
    } else {
      // Optional: loop to end
      this.currentIndex = this.maxIndex
      this.updatePosition()
    }
  }

  updatePosition() {
    const offset = -1 * this.currentIndex * (this.itemWidth + this.gap)
    this.trackTarget.style.transform = `translateX(${offset}px)`
  }

  // Touch event handlers for mobile swipe
  handleTouchStart(event) {
    this.touchStartX = event.changedTouches[0].screenX
  }

  handleTouchEnd(event) {
    this.touchEndX = event.changedTouches[0].screenX
    this.handleSwipe()
  }

  handleSwipe() {
    const swipeThreshold = 50 // Minimum distance to register as a swipe
    const swipeDistance = this.touchEndX - this.touchStartX

    if (swipeDistance > swipeThreshold) {
      // Swiped right, go to previous
      this.prev()
    } else if (swipeDistance < -swipeThreshold) {
      // Swiped left, go to next
      this.next()
    }
  }

  // Mouse drag handlers
  handleMouseDown(event) {
    this.isDragging = true
    this.dragStartX = event.clientX
    this.dragStartOffset = -1 * this.currentIndex * (this.itemWidth + this.gap)

    // Add event listeners for mouse move and up
    document.addEventListener('mousemove', this.handleMouseMove.bind(this))
    document.addEventListener('mouseup', this.handleMouseUp.bind(this))

    // Prevent default to avoid text selection during drag
    event.preventDefault()
  }

  handleMouseMove(event) {
    if (!this.isDragging) return

    const dragDistance = event.clientX - this.dragStartX
    const newOffset = this.dragStartOffset + dragDistance

    // Apply the new position with some constraints to prevent dragging too far
    const maxOffset = 0
    const minOffset = -1 * this.maxIndex * (this.itemWidth + this.gap)

    const constrainedOffset = Math.max(Math.min(newOffset, maxOffset), minOffset)
    this.trackTarget.style.transform = `translateX(${constrainedOffset}px)`
  }

  handleMouseUp(event) {
    if (!this.isDragging) return

    this.isDragging = false

    // Calculate which index we should snap to based on the final position
    const dragDistance = event.clientX - this.dragStartX

    if (Math.abs(dragDistance) > 50) {
      // If dragged far enough, move to next/prev
      if (dragDistance > 0) {
        this.prev()
      } else {
        this.next()
      }
    } else {
      // If not dragged far enough, snap back to current index
      this.updatePosition()
    }

    // Remove event listeners
    document.removeEventListener('mousemove', this.handleMouseMove.bind(this))
    document.removeEventListener('mouseup', this.handleMouseUp.bind(this))
  }
}