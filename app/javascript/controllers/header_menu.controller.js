import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mobileMenu", 
    "menuIcon", 
    "closeIcon", 
    "dropdown", 
    "dropdownMenu",
    "notificationBadge"
  ]

  connect() {
    // Handle window resize to reset mobile menu state
    window.addEventListener('resize', this.handleResize.bind(this))
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', this.closeDropdownsOnClickOutside.bind(this))
    
    // Add scroll effects
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    document.removeEventListener('click', this.closeDropdownsOnClickOutside)
    window.removeEventListener('scroll', this.handleScroll)
  }

  toggleMenu() {
    const isOpen = this.mobileMenuTarget.classList.contains('translate-y-0')
    
    if (isOpen) {
      this.mobileMenuTarget.classList.remove('translate-y-0', 'opacity-100')
      this.mobileMenuTarget.classList.add('-translate-y-full', 'opacity-0')
      this.menuIconTarget.classList.remove('hidden')
      this.closeIconTarget.classList.add('hidden')
      document.body.classList.remove('overflow-hidden')
    } else {
      this.mobileMenuTarget.classList.remove('-translate-y-full', 'opacity-0')
      this.mobileMenuTarget.classList.add('translate-y-0', 'opacity-100')
      this.menuIconTarget.classList.add('hidden')
      this.closeIconTarget.classList.remove('hidden')
      document.body.classList.add('overflow-hidden')
    }
  }
  
  toggleDropdown(event) {
    event.preventDefault()
    
    const dropdown = event.currentTarget.closest("[data-header-target='dropdown']")
    const dropdownMenu = dropdown.querySelector("[data-header-target='dropdownMenu']")
    const isOpen = dropdown.getAttribute('aria-expanded') === 'true'
    
    // Close all other dropdowns first
    this.dropdownTargets.forEach(d => {
      if (d !== dropdown) {
        d.setAttribute('aria-expanded', 'false')
        d.querySelector("[data-header-target='dropdownMenu']").classList.add('opacity-0', 'invisible', '-translate-y-2')
        d.querySelector("[data-header-target='dropdownMenu']").classList.remove('opacity-100', 'visible', 'translate-y-0')
      }
    })
    
    // Toggle current dropdown
    dropdown.setAttribute('aria-expanded', !isOpen)
    if (isOpen) {
      dropdownMenu.classList.add('opacity-0', 'invisible', '-translate-y-2')
      dropdownMenu.classList.remove('opacity-100', 'visible', 'translate-y-0')
    } else {
      dropdownMenu.classList.remove('opacity-0', 'invisible', '-translate-y-2')
      dropdownMenu.classList.add('opacity-100', 'visible', 'translate-y-0')
    }
  }
  
  closeDropdownsOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTargets.forEach(dropdown => {
        dropdown.setAttribute('aria-expanded', 'false')
        const menu = dropdown.querySelector("[data-header-target='dropdownMenu']")
        menu.classList.add('opacity-0', 'invisible', '-translate-y-2')
        menu.classList.remove('opacity-100', 'visible', 'translate-y-0')
      })
    }
  }
  
  handleResize() {
    // Reset mobile menu on window resize
    if (window.innerWidth >= 768) { // md breakpoint
      this.mobileMenuTarget.classList.remove('translate-y-0', 'opacity-100')
      this.mobileMenuTarget.classList.add('-translate-y-full', 'opacity-0')
      this.menuIconTarget.classList.remove('hidden')
      this.closeIconTarget.classList.add('hidden')
      document.body.classList.remove('overflow-hidden')
    }
  }
  
  handleScroll() {
    // Add shadow and background effect on scroll
    if (window.scrollY > 10) {
      this.element.classList.add('shadow-lg', 'bg-opacity-95')
      this.element.classList.remove('shadow-sm', 'bg-opacity-100')
    } else {
      this.element.classList.remove('shadow-lg', 'bg-opacity-95')
      this.element.classList.add('shadow-sm', 'bg-opacity-100')
    }
  }
  
  // Update notification badge dynamically
  updateNotificationCount(count) {
    if (this.hasNotificationBadgeTarget) {
      if (count > 0) {
        this.notificationBadgeTarget.textContent = count > 99 ? '99+' : count
        this.notificationBadgeTarget.classList.remove('hidden')
      } else {
        this.notificationBadgeTarget.classList.add('hidden')
      }
    }
  }
}