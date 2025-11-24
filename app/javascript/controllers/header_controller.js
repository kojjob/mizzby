import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown", "dropdownContent", "mobileMenu", "searchOverlay"]
  
  connect() {
    // Bind and store handlers so we can remove them correctly later
    this.boundOutsideClickHandler = this.closeDropdownsOnClickOutside.bind(this)
    this.boundKeydownHandler = this.handleKeyDown.bind(this)

    // Close dropdowns when clicking outside
    document.addEventListener('click', this.boundOutsideClickHandler)

    // Handle escape key to close dropdowns and search
    document.addEventListener('keydown', this.boundKeydownHandler)
  }

  disconnect() {
    // Clean up with the same bound references
    if (this.boundOutsideClickHandler) document.removeEventListener('click', this.boundOutsideClickHandler)
    if (this.boundKeydownHandler) document.removeEventListener('keydown', this.boundKeydownHandler)
  }

  toggleDropdown(event) {
    event.preventDefault()
    const dropdownId = event.currentTarget.dataset.dropdownId
    
    // Close all other dropdowns first
    this.dropdownContentTargets.forEach(dropdown => {
      if (dropdown.dataset.dropdownFor !== dropdownId) {
        dropdown.classList.add('hidden')
      }
    })
    
    // Toggle the clicked dropdown
    const dropdown = this.dropdownContentTargets.find(
      dropdown => dropdown.dataset.dropdownFor === dropdownId
    )
    
    if (dropdown) {
      dropdown.classList.toggle('hidden')
      event.currentTarget.setAttribute(
        'aria-expanded', 
        dropdown.classList.contains('hidden') ? 'false' : 'true'
      )
    }
  }
  
  toggleMobileMenu(event) {
    event.preventDefault()
    this.mobileMenuTarget.classList.toggle('hidden')
  }
  
  toggleSearch(event) {
    event.preventDefault()
    this.searchOverlayTarget.classList.remove('hidden')
    
    // Focus the search input
    setTimeout(() => {
      this.searchOverlayTarget.querySelector('input').focus()
    }, 100)
    
    // Close all dropdowns
    this.dropdownContentTargets.forEach(dropdown => {
      dropdown.classList.add('hidden')
    })
  }
  
  closeSearch(event) {
    event.preventDefault()
    this.searchOverlayTarget.classList.add('hidden')
  }
  
  handleSearchKeydown(event) {
    // Close search on escape key
    if (event.key === 'Escape') {
      this.closeSearch(event)
    }
  }
  
  // app/javascript/controllers/header_controller.js (continued)
  closeDropdownsOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      // Close all dropdowns
      this.dropdownContentTargets.forEach(dropdown => {
        dropdown.classList.add('hidden')
      })
      
      // Update aria-expanded attributes
      this.dropdownTargets.forEach(dropdown => {
        const button = dropdown.querySelector('[aria-expanded]')
        if (button) {
          button.setAttribute('aria-expanded', 'false')
        }
      })
    }
  }
  
  handleKeyDown(event) {
    if (event.key === 'Escape') {
      // Close all dropdowns
      this.dropdownContentTargets.forEach(dropdown => {
        dropdown.classList.add('hidden')
      })
      
      // Update aria-expanded attributes
      this.dropdownTargets.forEach(dropdown => {
        const button = dropdown.querySelector('[aria-expanded]')
        if (button) {
          button.setAttribute('aria-expanded', 'false')
        }
      })
      
      // Close search overlay
      if (!this.searchOverlayTarget.classList.contains('hidden')) {
        this.closeSearch(event)
      }
    }
  }
}