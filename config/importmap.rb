# Pin npm packages by running ./bin/importmap

pin 'application', preload: true

# Hotwired Stimulus (provided by stimulus-rails gem)
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true

# Turbo (provided by turbo-rails gem)
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

# Pin custom application files from app/javascript
pin_all_from 'app/javascript'
pin "@rails/actioncable", to: "actioncable.esm.js"
