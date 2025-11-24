import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Related products controller connected")
    // Could implement additional functionality like lazy loading
    
    // or carousel behavior for related products
  }
}