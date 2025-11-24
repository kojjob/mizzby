import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Trending carousel controller connected")
  }
  
  scrollLeft() {
    const container = this.element.querySelector('.overflow-x-auto')
    container.scrollBy({
      left: -300,
      behavior: 'smooth'
    })
  }
  
  scrollRight() {
    const container = this.element.querySelector('.overflow-x-auto')
    container.scrollBy({
      left: 300,
      behavior: 'smooth'
    })
  }
}
