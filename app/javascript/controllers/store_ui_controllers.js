// Import Stimulus controllers for the enhanced store UI
import { Controller } from "@hotwired/stimulus"

// Mobile Menu Controller
export class MobileMenuController extends Controller {
  static targets = ["menu", "categories"]
  
  connect() {
    // Initialize mobile menu closed
    this.menuTarget.classList.add("hidden");
  }
  
  toggle() {
    this.menuTarget.classList.toggle("hidden");
  }
  
  toggleSubmenu(event) {
    const targetName = event.currentTarget.dataset.target;
    const targetElement = this[`${targetName}Target`];
    
    targetElement.classList.toggle("hidden");
    
    // Toggle the arrow icon
    const icon = event.currentTarget.querySelector("svg");
    if (targetElement.classList.contains("hidden")) {
      icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />';
    } else {
      icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l-7 7 7 7" />';
    }
  }
}

// Sticky Header Controller
export class StickyHeaderController extends Controller {
  static targets = ["content"]
  
  connect() {
    this.threshold = 100; // Pixels scrolled before sticky
    this.scrollY = window.scrollY;
    this.scrollListener = this.handleScroll.bind(this);
    window.addEventListener('scroll', this.scrollListener);
    
    // Initialize header state
    this.handleScroll();
  }
  
  disconnect() {
    window.removeEventListener('scroll', this.scrollListener);
  }
  
  handleScroll() {
    const newScrollY = window.scrollY;
    
    if (newScrollY > this.threshold) {
      this.makeSticky();
    } else {
      this.makeNormal();
    }
    
    this.scrollY = newScrollY;
  }
  
  makeSticky() {
    this.contentTarget.classList.add('fixed', 'top-0', 'left-0', 'right-0', 'z-50', 'shadow-md', 'py-2', 'animate-slideDown', 'bg-white');
    
    // Add padding to prevent content jump
    if (!this.paddingElement) {
      this.paddingElement = document.createElement('div');
      this.paddingElement.style.height = `${this.contentTarget.offsetHeight}px`;
      this.element.appendChild(this.paddingElement);
    }
  }
  
  makeNormal() {
    this.contentTarget.classList.remove('fixed', 'top-0', 'left-0', 'right-0', 'z-50', 'shadow-md', 'py-2', 'animate-slideDown');
    
    // Remove padding element
    if (this.paddingElement) {
      this.element.removeChild(this.paddingElement);
      this.paddingElement = null;
    }
  }
}

// Dropdown Controller for Navigation Menus
export class DropdownController extends Controller {
  static targets = ["menu"]
  
  connect() {
    this.menuTarget.classList.add("hidden");
    
    // Close dropdown when clicking outside
    this.clickOutsideListener = this.clickOutside.bind(this);
    document.addEventListener("click", this.clickOutsideListener);
  }
  
  disconnect() {
    document.removeEventListener("click", this.clickOutsideListener);
  }
  
  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("hidden");
  }
  
  clickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden");
    }
  }
}

// Parallax Effect Controller
export class ParallaxController extends Controller {
  static targets = ["element"]
  static values = { speed: Number }
  
  connect() {
    this.speedValue = this.speedValue || 0.1;
    this.scrollListener = this.scroll.bind(this);
    window.addEventListener('scroll', this.scrollListener);
    this.scroll();
  }
  
  disconnect() {
    window.removeEventListener('scroll', this.scrollListener);
  }
  
  scroll() {
    const scrollY = window.scrollY;
    this.element.style.transform = `translateY(${scrollY * this.speedValue}px)`;
  }
}

// Animation On Scroll Controller
export class AnimateOnScrollController extends Controller {
  static values = { 
    animation: String,
    delay: { type: Number, default: 0 },
    threshold: { type: Number, default: 0.2 },
    stagger: { type: Number, default: 0 }
  }
  
  connect() {
    this.observer = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            if (this.element.children.length > 0 && this.staggerValue > 0) {
              // Apply staggered animation to children
              Array.from(this.element.children).forEach((child, index) => {
                setTimeout(() => {
                  child.style.animation = `${this.animationValue} 1s forwards`;
                  child.style.opacity = 0;
                }, this.delayValue + (index * this.staggerValue));
              });
            } else {
              // Apply animation to the element itself
              setTimeout(() => {
                this.element.style.animation = `${this.animationValue} 1s forwards`;
              }, this.delayValue);
            }
            this.observer.unobserve(this.element);
          }
        });
      },
      { threshold: this.thresholdValue }
    );
    
    // Set initial opacity to 0
    if (this.staggerValue > 0 && this.element.children.length > 0) {
      Array.from(this.element.children).forEach(child => {
        child.style.opacity = 0;
      });
    } else {
      this.element.style.opacity = 0;
    }
    
    this.observer.observe(this.element);
  }
  
  disconnect() {
    this.observer.disconnect();
  }
}

// Carousel Controller
export class CarouselController extends Controller {
  static targets = ["track", "container", "dots"]
  
  connect() {
    this.currentIndex = 0;
    this.itemsPerPage = this.getItemsPerPage();
    this.updateDots();
    this.setupResizeListener();
  }
  
  getItemsPerPage() {
    return window.innerWidth < 640 ? 1 : 
           window.innerWidth < 1024 ? 2 : 4;
  }
  
  setupResizeListener() {
    this.resizeListener = this.handleResize.bind(this);
    window.addEventListener('resize', this.resizeListener);
  }
  
  handleResize() {
    const newItemsPerPage = this.getItemsPerPage();
    if (newItemsPerPage !== this.itemsPerPage) {
      this.itemsPerPage = newItemsPerPage;
      this.goto(0);
    }
  }
  
  prev() {
    const newIndex = Math.max(0, this.currentIndex - 1);
    this.goto(newIndex);
  }
  
  next() {
    const items = this.trackTarget.children;
    const totalItems = items.length;
    const maxIndex = Math.ceil(totalItems / this.itemsPerPage) - 1;
    const newIndex = Math.min(maxIndex, this.currentIndex + 1);
    this.goto(newIndex);
  }
  
  goto(index) {
    this.currentIndex = parseInt(index);
    
    const containerWidth = this.containerTarget.offsetWidth;
    const translateX = -(containerWidth * this.currentIndex);
    
    this.trackTarget.style.transform = `translateX(${translateX}px)`;
    this.updateDots();
  }
  
  updateDots() {
    if (this.hasDotTarget) {
      const dots = this.dotsTarget.children;
      Array.from(dots).forEach((dot, index) => {
        if (index === this.currentIndex) {
          dot.classList.add('bg-indigo-600');
          dot.classList.remove('bg-gray-300');
        } else {
          dot.classList.add('bg-gray-300');
          dot.classList.remove('bg-indigo-600');
        }
      });
    }
  }
  
  disconnect() {
    window.removeEventListener('resize', this.resizeListener);
  }
}

// Testimonials Slider Controller
export class TestimonialsSliderController extends Controller {
  static targets = ["track", "container", "dots"]
  
  connect() {
    this.currentIndex = 0;
    this.updateDots();
    this.containerWidth = this.containerTarget.offsetWidth;
    this.setupResizeListener();
  }
  
  setupResizeListener() {
    this.resizeListener = this.handleResize.bind(this);
    window.addEventListener('resize', this.resizeListener);
  }
  
  handleResize() {
    const newContainerWidth = this.containerTarget.offsetWidth;
    if (newContainerWidth !== this.containerWidth) {
      this.containerWidth = newContainerWidth;
      this.goto(this.currentIndex);
    }
  }
  
  prev() {
    const newIndex = Math.max(0, this.currentIndex - 1);
    this.goto(newIndex);
  }
  
  next() {
    const items = this.trackTarget.children;
    const totalItems = items.length;
    const newIndex = Math.min(totalItems - 1, this.currentIndex + 1);
    this.goto(newIndex);
  }
  
  goto(index) {
    this.currentIndex = parseInt(index);
    
    const translateX = -(this.containerWidth * this.currentIndex);
    
    this.trackTarget.style.transform = `translateX(${translateX}px)`;
    this.updateDots();
  }
  
  updateDots() {
    if (this.hasDotTarget) {
      const dots = this.dotsTarget.children;
      Array.from(dots).forEach((dot, index) => {
        if (index === this.currentIndex) {
          dot.classList.add('bg-indigo-600');
          dot.classList.remove('bg-gray-300');
        } else {
          dot.classList.add('bg-gray-300');
          dot.classList.remove('bg-indigo-600');
        }
      });
    }
  }
  
  disconnect() {
    window.removeEventListener('resize', this.resizeListener);
  }
}

// Announcement Bar Controller
export class AnnouncementBarController extends Controller {
  connect() {
    this.originalContent = this.element.innerHTML;
    this.setupMobileAnnouncement();
    this.setupResizeListener();
  }
  
  setupMobileAnnouncement() {
    if (window.innerWidth < 768) {
      this.startRotation();
    } else {
      this.stopRotation();
    }
  }
  
  setupResizeListener() {
    this.resizeListener = this.handleResize.bind(this);
    window.addEventListener('resize', this.resizeListener);
  }
  
  handleResize() {
    this.setupMobileAnnouncement();
  }
  
  startRotation() {
    if (!this.rotationInterval) {
      const announcements = [
        '🎉 Welcome to our store!',
        '🚚 Free shipping over $50',
        '🔥 Use code WELCOME15 for 15% off'
      ];
      
      let currentIndex = 0;
      const announcementText = this.element.querySelector('p');
      
      this.rotationInterval = setInterval(() => {
        currentIndex = (currentIndex + 1) % announcements.length;
        announcementText.innerHTML = `<span class="inline-block">${announcements[currentIndex]}</span>`;
      }, 3000);
    }
  }
  
  stopRotation() {
    if (this.rotationInterval) {
      clearInterval(this.rotationInterval);
      this.rotationInterval = null;
      this.element.innerHTML = this.originalContent;
    }
  }
  
  disconnect() {
    this.stopRotation();
    window.removeEventListener('resize', this.resizeListener);
  }
}

// Newsletter Form Controller
export class NewsletterFormController extends Controller {
  connect() {
    this.element.addEventListener('submit', this.handleSubmit.bind(this));
  }
  
  handleSubmit(event) {
    event.preventDefault();
    
    // Get the email input
    const emailInput = this.element.querySelector('input[type="email"]');
    const email = emailInput ? emailInput.value : '';
    
    if (email && this.validateEmail(email)) {
      // Success state - in production this would submit to backend
      this.element.innerHTML = `
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative" role="alert">
          <strong class="font-bold">Thank you!</strong>
          <span class="block sm:inline"> You've been successfully subscribed to our newsletter.</span>
        </div>
      `;
    } else {
      // Show error for invalid email
      if (emailInput) {
        emailInput.classList.add('border-red-500', 'bg-red-50');
        
        // Add error message if not already present
        const parent = emailInput.parentNode;
        let errorMsg = parent.querySelector('.text-red-500');
        
        if (!errorMsg) {
          errorMsg = document.createElement('p');
          errorMsg.className = 'text-red-500 text-xs italic mt-1 text-left';
          errorMsg.textContent = 'Please enter a valid email address';
          parent.appendChild(errorMsg);
        }
      }
    }
  }
  
  validateEmail(email) {
    const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
  }
}

// Register all controllers with Stimulus
const application = window.Stimulus;
if (application) {
  application.register("mobile-menu", MobileMenuController);
  application.register("sticky-header", StickyHeaderController);
  application.register("dropdown", DropdownController);
  application.register("parallax", ParallaxController);
  application.register("animate-on-scroll", AnimateOnScrollController);
  application.register("carousel", CarouselController);
  application.register("testimonials-slider", TestimonialsSliderController);
  application.register("announcement-bar", AnnouncementBarController);
  application.register("newsletter-form", NewsletterFormController);
}

// Add CSS animations to document
document.addEventListener('DOMContentLoaded', () => {
  // Add CSS animations
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideDown {
      from {
        transform: translateY(-100%);
      }
      to {
        transform: translateY(0);
      }
    }
    
    .animate-slideDown {
      animation: slideDown 0.3s ease-out forwards;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    
    @keyframes fadeInUp {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
    
    @keyframes fadeInDown {
      from {
        opacity: 0;
        transform: translateY(-20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }
    
    @keyframes fadeInLeft {
      from {
        opacity: 0;
        transform: translateX(-20px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }
    
    @keyframes fadeInRight {
      from {
        opacity: 0;
        transform: translateX(20px);
      }
      to {
        opacity: 1;
        transform: translateX(0);
      }
    }
    
    /* Category Card Pattern Animation */
    .category-pattern {
      animation: patternMove 30s linear infinite;
    }
    
    @keyframes patternMove {
      0% {
        background-position: 0 0;
      }
      100% {
        background-position: 100px 100px;
      }
    }
    
    /* Hide Scrollbar */
    .hide-scrollbar {
      -ms-overflow-style: none;  /* IE and Edge */
      scrollbar-width: none;  /* Firefox */
    }
    .hide-scrollbar::-webkit-scrollbar {
      display: none; /* Chrome, Safari, Opera */
    }
    
    /* 3D Perspective Effect */
    .perspective-3d {
      perspective: 1000px;
    }
    
    .rotate-y-6:hover {
      transform: rotateY(6deg) scale(1.05);
    }
    
    /* Shadow Text for Better Contrast */
    .shadow-text {
      text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
    }
    
    /* Line clamp for text truncation */
    .line-clamp-1 {
      display: -webkit-box;
      -webkit-line-clamp: 1;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .line-clamp-2 {
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .line-clamp-3 {
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
  `;
  document.head.appendChild(style);
});
