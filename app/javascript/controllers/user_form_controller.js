import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "toggleButton"];

  toggle() {
    if (this.toggleButtonTarget.textContent === "Hide") {
      this.hide();
    } else {
      this.show();
    }
  }

  show() {
    this.formTarget.style.overflow = "hidden";
    this.formTarget.style.animation = "scaleUp .6s ease-in-out forwards";
    this.toggleButtonTarget.textContent = "Hide";
  }

  hide() {
    this.formTarget.style.overflow = "hidden";
    this.formTarget.style.animation = "scaleDown .6s ease-in-out forwards";
    this.toggleButtonTarget.textContent = "Show";
  }
}
