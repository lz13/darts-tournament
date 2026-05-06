import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "output"]

  // connect() {
  //   this.element.textContent = "Hello World!"
  // }

  greet() {
    const name = this.nameTarget.value.trim()
    if (name) {
      this.outputTarget.textContent = `Hello, ${name}! Stimulus is working.`
    } else {
      this.outputTarget.textContent = "Please enter a name first!"
    }
  }
}
