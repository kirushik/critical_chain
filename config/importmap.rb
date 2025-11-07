# Pin npm packages by running ./bin/importmap

pin "application", preload: true

# jQuery - Using ESM-compatible version from ga.jspm.io
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js", preload: true

# jQuery UI - Using ESM-compatible version from ga.jspm.io
pin "jquery-ui", to: "https://ga.jspm.io/npm:jquery-ui@1.13.2/dist/jquery-ui.js"

# Popper.js - Required by Bootstrap 4
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"

# Bootstrap 4 JavaScript - Using bundle that includes Popper
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"

# X-editable - Using UMD build from cdnjs (not an ES module, will need shimming)
pin "bootstrap-editable", to: "https://cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.1/bootstrap3-editable/js/bootstrap-editable.min.js"

# Turbo (already included via gem)
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Pin custom application files
pin_all_from "app/javascript"
