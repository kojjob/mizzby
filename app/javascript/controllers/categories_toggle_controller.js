import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["themeToggle", "darkIcon", "lightIcon"]

  connect() {
    this.themeToggle = document.getElementById('theme-toggle')
    this.darkIcon = document.getElementById('theme-toggle-dark-icon')
    this.lightIcon = document.getElementById('theme-toggle-light-icon')
    
    // Check for saved theme or system preference
    this.savedTheme = localStorage.getItem('color-theme')
    this.systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)')

    // Initial theme setup
    this.setTheme(this.savedTheme)

    // Theme toggle button
    this.themeToggle.addEventListener('click', () => {
      const currentTheme = document.documentElement.classList.contains('dark') ? 'dark' : 'light'
      this.setTheme(currentTheme === 'light' ? 'dark' : 'light')
    })

    // System theme change listener
    this.systemPrefersDark.addEventListener('change', (e) => {
      if (!localStorage.getItem('color-theme')) {
        this.setTheme(e.matches ? 'dark' : 'light')
      }
    })
  }

  disconnect() {
    // Clean up event listeners
    this.systemPrefersDark.removeEventListener('change')
    this.themeToggle.removeEventListener('click')
  }

  setTheme(theme) {
    if (theme === 'dark' || (!this.savedTheme && this.systemPrefersDark.matches)) {
      document.documentElement.classList.add('dark')
      this.darkIcon.classList.remove('hidden')
      this.lightIcon.classList.add('hidden')
      localStorage.setItem('color-theme', 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      this.lightIcon.classList.remove('hidden')
      this.darkIcon.classList.add('hidden')
      localStorage.setItem('color-theme', 'light')
    }
  }
}