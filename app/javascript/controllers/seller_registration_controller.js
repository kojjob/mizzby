import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.toggleSellerBenefits();
    
    // Add event listener to the checkbox
    const checkbox = document.getElementById('become_seller');
    if (checkbox) {
      checkbox.addEventListener('change', () => {
        this.toggleSellerBenefits();
      });
    }
  }
  
  toggleSellerBenefits() {
    const checkbox = document.getElementById('become_seller');
    const benefits = document.getElementById('seller-benefits');
    
    if (checkbox && benefits) {
      if (checkbox.checked) {
        benefits.classList.remove('hidden');
      } else {
        benefits.classList.add('hidden');
      }
    }
  }
}
