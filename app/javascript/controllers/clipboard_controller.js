import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static values = { text: String }

  // connect() {
  //
  // }

  copy(event) {
    const button = event.currentTarget
    const originalHTML = button.innerHTML

    navigator.clipboard.writeText(this.textValue).then(() => {
      button.innerHTML = "Copied!"
      setTimeout(() => {
        button.innerHTML = originalHTML
      }, 2000)
    }).catch(() => {
      button.innerHTML = "Failed to copy!"
    })
  }
}
