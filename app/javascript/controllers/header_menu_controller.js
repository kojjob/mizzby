// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["mobileMenu", "menuIcon", "closeIcon"]
//   static values = {
//     menuOpen: { type: Boolean, default: false }
//   }

//   connect() {
//     // Initialize scroll effect
//     this.lastScrollY = window.scrollY
//     this.scrollHandler = this.handleScroll.bind(this)
//     window.addEventListener('scroll', this.scrollHandler)
    
//     // Initialize mobile menu state
//     this.closeMobileMenu()
    
//     // Handle resize to close menu on desktop view
//     this.resizeHandler = this.handleResize.bind(this)
//     window.addEventListener('resize', this.resizeHandler)
    
//     // Trigger initial scroll handler to set correct state
//     this.handleScroll()
//   }
  
//   disconnect() {
//     window.removeEventListener('scroll', this.scrollHandler)
//     window.removeEventListener('resize', this.resizeHandler)
//   }
  
//   handleScroll() {
//     // Avoid unnecessary DOM operations if scroll position hasn't changed significantly
//     const currentScroll = window.scrollY
    
//     // Apply scroll-based styles
//     if (currentScroll > 50) {
//       this.element.classList.add('bg-opacity-95', 'backdrop-blur-sm', 'py-2')
//       this.element.classList.remove('py-4')
      
//       // Hide header when scrolling down past threshold, show when scrolling up
//       if (this.lastScrollY < currentScroll && currentScroll > 300) {
//         this.element.classList.add('transform', '-translate-y-full')
//       } else {
//         this.element.classList.remove('transform', '-translate-y-full')
//       }
//     } else {
//       // Reset to default styles when at top
//       this.element.classList.remove('bg-opacity-95', 'backdrop-blur-sm', 'py-2', 'transform', '-translate-y-full')
//       this.element.classList.add('py-4')
//     }
    
//     this.lastScrollY = currentScroll
//   }
  
//   handleResize() {
//     // Close mobile menu when window is resized to desktop size
//     if (window.innerWidth >= 768 && this.menuOpenValue) {
//       this.closeMobileMenu()
//     }
//   }
  
//   toggleMenu(event) {
//     if (event) event.preventDefault()
    
//     if (this.menuOpenValue) {
//       this.closeMobileMenu()
//     } else {
//       this.openMobileMenu()
//     }
//   }
  
//   openMobileMenu() {
//     if (!this.hasMobileMenuTarget) return
    
//     // Update state
//     this.menuOpenValue = true
    
//     // Update UI - mobile menu
//     this.mobileMenuTarget.classList.remove('translate-y-full')
//     this.mobileMenuTarget.classList.add('translate-y-0')
    
//     // Update UI - toggle icons
//     if (this.hasMenuIconTarget && this.hasCloseIconTarget) {
//       this.menuIconTarget.classList.add('hidden')
//       this.closeIconTarget.classList.remove('hidden')
//     }
    
//     // Prevent body scrolling when menu is open
//     document.body.style.overflow = 'hidden'
    
//     // Add click outside listener
//     this.clickOutsideHandler = this.handleClickOutside.bind(this)
//     setTimeout(() => {
//       document.addEventListener('click', this.clickOutsideHandler)
//     }, 10)
//   }
  
//   closeMobileMenu() {
//     if (!this.hasMobileMenuTarget) return
    
//     // Update state
//     this.menuOpenValue = false
    
//     // Update UI - mobile menu
//     this.mobileMenuTarget.classList.remove('translate-y-0')
//     this.mobileMenuTarget.classList.add('translate-y-full')
    
//     // Update UI - toggle icons
//     if (this.hasMenuIconTarget && this.hasCloseIconTarget) {
//       this.menuIconTarget.classList.remove('hidden')
//       this.closeIconTarget.classList.add('hidden')
//     }
    
//     // Restore body scrolling
//     document.body.style.overflow = ''
    
//     // Remove click outside listener
//     if (this.clickOutsideHandler) {
//       document.removeEventListener('click', this.clickOutsideHandler)
//     }
//   }
  
//   handleClickOutside(event) {
//     // Only check if menu is open
//     if (!this.menuOpenValue) return
    
//     // Ignore clicks on the menu button itself
//     const toggleButton = this.element.querySelector('[data-action="click->header-menu#toggleMenu"]')
//     if (toggleButton && toggleButton.contains(event.target)) return
    
//     // Close if click is outside the mobile menu
//     if (this.hasMobileMenuTarget && !this.mobileMenuTarget.contains(event.target)) {
//       this.closeMobileMenu()
//     }
//   }
// }
