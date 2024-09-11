import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"];

  hide() {
    console.log("Hiding form");
    this.formTarget.classList.add("hidden");
  }
}
