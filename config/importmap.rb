# Pin npm packages by running ./bin/importmap

pin "application", preload: true

# jQuery is loaded directly via script tag in layout for immediate global availability
# This ensures compatibility with jQuery plugins and legacy code that expect window.$

# jQuery UI - Using ESM-compatible version from ga.jspm.io
pin "jquery-ui", to: "https://ga.jspm.io/npm:jquery-ui@1.13.2/dist/jquery-ui.js"

# Popper.js - Required by Bootstrap 4
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"

# Bootstrap 4 JavaScript - Using bundle that includes Popper
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"

# X-editable is loaded as script tag, not module (not available as ES module)

# Turbo (already included via gem)
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Pin custom application files
pin_all_from "app/javascript"
