import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="menu-dropdown"
export default class extends Controller {
  static targets = ["dropdown"];

  connect() {
    this.addEventListeners();
    this.setupHoverBehavior();
  }

  disconnect() {
    this.removeEventListeners();
  }

  addEventListeners() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this);
    this.boundHandleEscapeKey = this.handleEscapeKey.bind(this);
    document.addEventListener("click", this.boundHandleClickOutside);
    document.addEventListener("keydown", this.boundHandleEscapeKey);
  }

  removeEventListeners() {
    document.removeEventListener("click", this.boundHandleClickOutside);
    document.removeEventListener("keydown", this.boundHandleEscapeKey);
    if (this.mouseEnterHandler && this.mouseLeaveHandler) {
      this.element.removeEventListener("mouseenter", this.mouseEnterHandler);
      this.element.removeEventListener("mouseleave", this.mouseLeaveHandler);
    }
  }

  setupHoverBehavior() {
    if (window.matchMedia("(min-width: 1024px)").matches) {
      this.mouseEnterHandler = () => this.show();
      this.mouseLeaveHandler = () => this.hide();
      this.element.addEventListener("mouseenter", this.mouseEnterHandler);
      this.element.addEventListener("mouseleave", this.mouseLeaveHandler);
    }
  }

  toggle(event) {
    event.stopPropagation();
    this.isVisible() ? this.hide() : this.show();
  }

  show() {
    this.closeOtherDropdowns();
    this.updateDropdownVisibility(true);
  }

  hide() {
    this.updateDropdownVisibility(false);
  }

  updateDropdownVisibility(visible) {
    this.dropdownTarget.classList.toggle("hidden", !visible);
    this.dropdownTarget.classList.toggle("block", visible);
    this.dropdownTarget.classList.toggle("opacity-100", visible);
    this.dropdownTarget.classList.toggle("translate-y-0", visible);
    this.dropdownTarget.classList.toggle("opacity-0", !visible);
    this.dropdownTarget.classList.toggle("translate-y-2", !visible);
    this.element.querySelector("button").setAttribute("aria-expanded", visible);
  }

  closeOtherDropdowns() {
    this.application.controllers
      .filter(controller => controller.identifier === "menu-dropdown" && controller.element !== this.element)
      .forEach(controller => controller.hide());
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && this.isVisible()) {
      this.hide();
    }
  }

  handleEscapeKey(event) {
    if (event.key === "Escape" && this.isVisible()) {
      this.hide();
    }
  }

  isVisible() {
    return !this.dropdownTarget.classList.contains("hidden");
  }
}