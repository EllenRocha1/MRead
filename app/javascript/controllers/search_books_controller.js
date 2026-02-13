import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "loading"]
  
  prevent(event) {
    event.preventDefault()
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.performSearch()
    }, 500)
  }

  performSearch() {
    const query = this.inputTarget.value.trim()
    const frame = document.getElementById("results_frame")

    if (query.length < 3) {
      if (frame) frame.src = "" 
      return
    }

    this.loadingTarget.classList.remove("d-none")

    if (frame) {
      frame.src = `/books/search?query=${encodeURIComponent(query)}`
    }
  
  }

  hideLoading() {
    this.loadingTarget.classList.add("d-none")
  }
}