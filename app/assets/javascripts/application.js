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
//= require vanilla-ujs
//= require turbolinks
//= require_tree .

var activate_editables = function () {
  Turbolinks.enableTransitionCache();
  console.log('QQQ!')
  // $('.editable').editable({success: function(response, newValue) {
  //   if(!response.success) return response.msg; //msg will be shown in editable form
  //   var vals = response.additionalValues;
  //   if(vals) {
  //     $('#total').text(vals.total);
  //     $('#sum').text(vals.sum);
  //     $('#buffer').text(vals.buffer);
  //     $('#actual_sum').text(vals.actual_sum);
  //     $('#buffer_health').text(vals.buffer_health);
  //     $('#buffer_health').attr('class', vals.buffer_health_class);
  //   }
  // }});
}

document.addEventListener("DOMContentLoaded", activate_editables);
