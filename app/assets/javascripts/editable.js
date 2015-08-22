HTMLDocument.prototype.activate_editables = function() {
  var editables = document.getElementsByClassName('editable');
  Array.prototype.forEach.call(editables, function(editable) {
    editable.onblur = function() {
      var data = {};
      data[editable.dataset.object] = {};
      data[editable.dataset.object][editable.dataset.field] = editable.value;

      LiteAjax.ajax(editable.dataset.path, {data: data, method: 'PATCH', json: true})
    }

    editable.onkeypress = function(e){
    if (!e) e = window.event;
    var keyCode = e.keyCode || e.which;
    if (keyCode == '13'){
      editable.blur();
      return false;
    }
  }
  });
}
