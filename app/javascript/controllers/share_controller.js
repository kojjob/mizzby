import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="share"
export default class extends Controller {
  static targets = ["dropdown", "copyButton", "copyText"]
  static values = {
    url: String,
    title: String,
    description: String,
    image: String
  }

  connect() {
    // Close dropdown when clicking outside
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden")
    }
  }

  close() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden")
    }
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // Native Web Share API (mobile-friendly)
  async nativeShare(event) {
    event.preventDefault()
    
    if (navigator.share) {
      try {
        await navigator.share({
          title: this.titleValue || document.title,
          text: this.descriptionValue || "",
          url: this.urlValue || window.location.href
        })
        this.showNotification("Shared successfully!", "success")
      } catch (err) {
        if (err.name !== "AbortError") {
          // User didn't cancel, show fallback
          this.toggle(event)
        }
      }
    } else {
      // Fallback to dropdown for desktop
      this.toggle(event)
    }
    this.close()
  }

  // Share to Twitter/X
  shareTwitter(event) {
    event.preventDefault()
    const text = encodeURIComponent(this.titleValue || document.title)
    const url = encodeURIComponent(this.urlValue || window.location.href)
    const twitterUrl = `https://twitter.com/intent/tweet?text=${text}&url=${url}`
    this.openPopup(twitterUrl, "Share on X")
    this.close()
  }

  // Share to Facebook
  shareFacebook(event) {
    event.preventDefault()
    const url = encodeURIComponent(this.urlValue || window.location.href)
    const facebookUrl = `https://www.facebook.com/sharer/sharer.php?u=${url}`
    this.openPopup(facebookUrl, "Share on Facebook")
    this.close()
  }

  // Share to LinkedIn
  shareLinkedIn(event) {
    event.preventDefault()
    const url = encodeURIComponent(this.urlValue || window.location.href)
    const title = encodeURIComponent(this.titleValue || document.title)
    const linkedInUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${url}`
    this.openPopup(linkedInUrl, "Share on LinkedIn")
    this.close()
  }

  // Share to WhatsApp
  shareWhatsApp(event) {
    event.preventDefault()
    const text = encodeURIComponent(`${this.titleValue || document.title} ${this.urlValue || window.location.href}`)
    const whatsappUrl = `https://wa.me/?text=${text}`
    window.open(whatsappUrl, "_blank")
    this.close()
  }

  // Share via Email
  shareEmail(event) {
    event.preventDefault()
    const subject = encodeURIComponent(this.titleValue || document.title)
    const body = encodeURIComponent(`Check out this product: ${this.urlValue || window.location.href}\n\n${this.descriptionValue || ""}`)
    window.location.href = `mailto:?subject=${subject}&body=${body}`
    this.close()
  }

  // Share to Pinterest
  sharePinterest(event) {
    event.preventDefault()
    const url = encodeURIComponent(this.urlValue || window.location.href)
    const description = encodeURIComponent(this.titleValue || document.title)
    const media = encodeURIComponent(this.imageValue || "")
    const pinterestUrl = `https://pinterest.com/pin/create/button/?url=${url}&media=${media}&description=${description}`
    this.openPopup(pinterestUrl, "Pin on Pinterest")
    this.close()
  }

  // Copy link to clipboard
  async copyLink(event) {
    event.preventDefault()
    const url = this.urlValue || window.location.href
    
    try {
      await navigator.clipboard.writeText(url)
      
      // Update button text temporarily
      if (this.hasCopyTextTarget) {
        const originalText = this.copyTextTarget.textContent
        this.copyTextTarget.textContent = "Copied!"
        setTimeout(() => {
          this.copyTextTarget.textContent = originalText
        }, 2000)
      }
      
      this.showNotification("Link copied to clipboard!", "success")
    } catch (err) {
      // Fallback for older browsers
      const textArea = document.createElement("textarea")
      textArea.value = url
      textArea.style.position = "fixed"
      textArea.style.left = "-999999px"
      document.body.appendChild(textArea)
      textArea.select()
      
      try {
        document.execCommand("copy")
        this.showNotification("Link copied to clipboard!", "success")
      } catch (e) {
        this.showNotification("Failed to copy link", "error")
      }
      
      document.body.removeChild(textArea)
    }
    
    this.close()
  }

  openPopup(url, title) {
    const width = 600
    const height = 400
    const left = (window.innerWidth - width) / 2
    const top = (window.innerHeight - height) / 2
    window.open(
      url,
      title,
      `width=${width},height=${height},left=${left},top=${top},toolbar=no,menubar=no,scrollbars=yes,resizable=yes`
    )
  }

  showNotification(message, type = "success") {
    // Try to use the flash message system
    const flashContainer = document.getElementById("flash-container")
    const templateId = type === "success" ? "flash-template-success" : "flash-template-error"
    const template = document.getElementById(templateId)
    
    if (template && flashContainer) {
      const messageElement = template.content.cloneNode(true).firstElementChild
      const contentElement = messageElement.querySelector('.message-content')
      if (contentElement) {
        contentElement.textContent = message
      }
      flashContainer.prepend(messageElement)
      
      setTimeout(() => {
        messageElement.classList.add('opacity-0', 'translate-x-full')
        setTimeout(() => messageElement.remove(), 300)
      }, 3000)
      return
    }
    
    // Fallback toast
    const notification = document.createElement("div")
    notification.className = `fixed bottom-4 right-4 z-[10000] px-6 py-3 rounded-xl shadow-lg ${
      type === "success" ? "bg-gradient-to-r from-indigo-500 to-purple-500 text-white" : "bg-red-500 text-white"
    }`
    notification.textContent = message
    document.body.appendChild(notification)
    
    setTimeout(() => {
      notification.style.opacity = "0"
      setTimeout(() => notification.remove(), 300)
    }, 3000)
  }
}
