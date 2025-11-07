# Pin npm packages by running ./bin/importmap

pin "application", preload: true

# jQuery - Required for Bootstrap 4 and x-editable
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@1.12.4/dist/jquery.min.js", preload: true

# jQuery UI - For sortable drag-and-drop
pin "jquery-ui", to: "https://cdn.jsdelivr.net/npm/jquery-ui-dist@1.13.2/jquery-ui.min.js"

# Popper.js - Required by Bootstrap 4
pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"

# Bootstrap 4 JavaScript
pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"

# X-editable - In-place editing
pin "bootstrap-editable", to: "https://cdnjs.cloudflare.com/ajax/libs/x-editable/1.5.0/bootstrap-editable/js/bootstrap-editable.min.js"

# Turbo (already included via gem)
pin "@hotwired/turbo-rails", to: "turbo.min.js"

# Pin custom application files
pin_all_from "app/javascript"
