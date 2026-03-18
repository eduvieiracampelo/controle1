import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    console.log('Theme controller connected')
    this.applyTheme()
  }

  toggle() {
    console.log('Toggle clicked')
    const html = document.getElementById('html-root')
    const isDark = html.classList.toggle("dark")
    console.log('Dark mode:', isDark)
    localStorage.setItem("theme", isDark ? "dark" : "light")
    this.updateIcon(isDark)
  }

  applyTheme() {
    const saved = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const isDark = saved ? saved === "dark" : prefersDark

    const html = document.getElementById('html-root')
    html.classList.toggle("dark", isDark)
    console.log('Applied theme, isDark:', isDark)
    this.updateIcon(isDark)
  }

  updateIcon(isDark) {
    if (this.iconTarget) {
      this.iconTarget.innerHTML = isDark
        ? '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>'
        : '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path></svg>'
    }
  }
}
