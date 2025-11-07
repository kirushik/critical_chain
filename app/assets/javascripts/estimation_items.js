// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var activate_sortable = function() {
  $('.estimation-items-index tbody').sortable({
    axis: 'y',
    handle: '.drag-handle',
    cursor: 'move',
    update: function(e, ui) {
      var item_id = ui.item.attr('id').split('_').pop();
      var estimation_id = ui.item.closest('table').attr('id').split('_').pop();

      // Get the items before and after the moved item
      var prev_item = ui.item.prev();
      var next_item = ui.item.next();

      // Calculate new order position
      var prev_order = prev_item.length ? parseFloat(prev_item.data('order')) : 0;
      var next_order = next_item.length ? parseFloat(next_item.data('order')) : prev_order + 2;

      var new_order = (prev_order + next_order) / 2;

      // Update the data-order attribute
      ui.item.data('order', new_order);

      // Send AJAX request to update the order
      $.ajax({
        url: "/estimations/" + estimation_id + "/estimation_items/" + item_id,
        method: 'PATCH',
        dataType: 'json',
        data: {
          estimation_item: {
            order: new_order
          }
        },
        error: function(xhr, status, error) {
          console.error('Failed to update order:', error);
          // Revert the sortable on error
          $(this).sortable('cancel');
        }
      });
    }
  });
};

$(document).ready(activate_sortable);
document.addEventListener('turbo:load', activate_sortable);
document.addEventListener('turbo:render', activate_sortable);
