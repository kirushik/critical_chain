# Pin npm packages by running ./bin/importmap

pin "application", preload: true

# Hotwire Stimulus
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Turbo (already included via gem)
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Pin custom application files
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript"
