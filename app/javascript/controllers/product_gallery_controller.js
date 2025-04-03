import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumbnail", "mainImageContainer"]

  connect() {
    // Initialize the first thumbnail as selected
    if (this.thumbnailTargets.length > 0) {
      this.thumbnailTargets[0].classList.add('border-indigo-500')
      this.thumbnailTargets[0].classList.remove('border-transparent')
    }
  }

  selectImage(event) {
    // Get the clicked thumbnail and its index
    const clickedThumbnail = event.currentTarget
    const index = parseInt(clickedThumbnail.dataset.index)

    // Update the active state of all thumbnails
    this.thumbnailTargets.forEach(thumbnail => {
      thumbnail.classList.remove('border-indigo-500')
      thumbnail.classList.add('border-transparent')
    })

    // Mark the clicked thumbnail as active
    clickedThumbnail.classList.add('border-indigo-500')
    clickedThumbnail.classList.remove('border-transparent')

    // Get the image URL from the data attribute
    const imageUrl = clickedThumbnail.dataset.imageUrl

    // Update the main image
    this.mainImageContainerTarget.innerHTML = `
      <img src="${imageUrl}"
           class="w-full h-full object-cover object-center transition-transform duration-500 ease-out group-hover:scale-110"
           data-action="click->product-gallery#zoomImage">
    `
  }

  zoomImage(event) {
    // Get the clicked image
    const img = event.target;

    // Create a modal for the zoomed image
    const modal = document.createElement('div');
    modal.className = 'fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75 p-4';
    modal.style.opacity = '0';
    modal.style.transition = 'opacity 0.3s ease';

    // Create the zoomed image
    const zoomedImg = document.createElement('img');
    zoomedImg.src = img.src;
    zoomedImg.className = 'max-h-[90vh] max-w-[90vw] object-contain';

    // Add close functionality
    modal.addEventListener('click', () => {
      modal.style.opacity = '0';
      setTimeout(() => {
        document.body.removeChild(modal);
      }, 300);
    });

    // Append to the DOM
    modal.appendChild(zoomedImg);
    document.body.appendChild(modal);

    // Trigger animation
    setTimeout(() => {
      modal.style.opacity = '1';
    }, 10);

    // Prevent event bubbling
    event.stopPropagation();
  }
}