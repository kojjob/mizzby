import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['grid']

  updateCategory(event) {
    this.updateUrlParams('category_id', event.target.value)
  }

  updateSort(event) {
    this.updateUrlParams('sort', event.target.value)
  }

  setGridView() {
    this.gridTarget.classList.remove('list-view')
    this.gridTarget.classList.add('grid-view')
    localStorage.setItem('product-view', 'grid')
  }

  setListView() {
    this.gridTarget.classList.remove('grid-view')
    this.gridTarget.classList.add('list-view')
    localStorage.setItem('product-view', 'list')
  }

  connect() {
    // Restore view mode from local storage
    const savedView = localStorage.getItem('product-view')
    if (savedView === 'list') {
      this.setListView()
    } else {
      this.setGridView()
    }
  }

  updateUrlParams(key, value) {
    const url = new URL(window.location)
    
    // Remove the parameter if value is empty
    if (!value) {
      url.searchParams.delete(key)
    } else {
      url.searchParams.set(key, value)
    }

    // Optional: Remove page parameter when filters change
    url.searchParams.delete('page')

    // Use Turbo to load the new URL
    Turbo.visit(url.toString(), { action: 'replace' })
  }
}