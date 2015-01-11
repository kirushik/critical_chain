// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/effect-highlight
//= require turbolinks
//= require bootstrap-sprockets
//= require editable/bootstrap-editable
//= require editable/rails
//= require_tree .

var activate_editables = function () {
  $('.editable').editable({success: function(response, newValue) {
    var vals = response.additionalValues;
    if(vals) {
      $('#total').text(vals.total);
      $('#sum').text(vals.sum);
      $('#buffer').text(vals.buffer);
    }
  }});
}

$(document).ready(activate_editables);
$(document).on('page:load', activate_editables);