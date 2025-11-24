# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "header", to: "header.js"
pin "header_dropdowns", to: "header_dropdowns.js"
pin "alpine_init", to: "alpine_init.js"
pin "tab_helper", to: "tab_helper.js"
pin "alpinejs", to: "https://cdn.jsdelivr.net/npm/alpinejs@3.12.0/dist/cdn.min.js"

pin "stimulus-use" # @0.52.3
