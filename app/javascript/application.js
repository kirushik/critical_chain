// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// jQuery is loaded synchronously in the layout before this module loads,
// so it's already available as window.jQuery and window.$

// Import jQuery UI (depends on jQuery being global)
import "jquery-ui";

// Import Bootstrap (after jQuery since it depends on it)
import "bootstrap";

// Import Turbo
import "@hotwired/turbo-rails";

// Configure jQuery to include CSRF token in AJAX requests
$.ajaxSetup({
  beforeSend: function (xhr, settings) {
    if (settings.type !== "GET" && !this.crossDomain) {
      var token = $('meta[name="csrf-token"]').attr("content");
      if (token) {
        xhr.setRequestHeader("X-CSRF-Token", token);
      }
    }
  },
});

// Initialize x-editable on page load
// Note: x-editable is loaded via script tag in layout since it's not available as ES module
var activate_editables = function () {
  if (typeof $.fn.editable !== 'undefined') {
    $(".editable").editable({
      success: function (response, newValue) {
        if (!response.success) return response.msg; //msg will be shown in editable form
        var vals = response.additionalValues;
        if (vals) {
          $("#total").text(vals.total);
          $("#sum").text(vals.sum);
          $("#buffer").text(vals.buffer);
          $("#actual_sum").text(vals.actual_sum);
          $("#buffer_health").text(vals.buffer_health);
          $("#buffer_health").attr("class", vals.buffer_health_class);
          if (vals.update_item_total) {
            $(vals.update_item_total.item + " .total_value").text(
              vals.update_item_total.total,
            );
          }
        }
      },
    });
  }
};

// Run on page load and Turbo events
$(document).ready(activate_editables);
document.addEventListener("turbo:load", activate_editables);
document.addEventListener("turbo:render", activate_editables);

// Import custom JavaScript files
import "./estimation_items";
import "./estimations";
import "./welcome";
