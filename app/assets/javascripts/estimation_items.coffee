# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

activate_sortable = ->
  $('.estimation-items-index tbody').sortable
    axis: 'y'
    handle: '.drag-handle'
    cursor: 'move'
    update: (e, ui) ->
      item_id = ui.item.attr('id').split('_').pop()
      estimation_id = ui.item.closest('table').attr('id').split('_').pop()
      
      # Get the items before and after the moved item
      prev_item = ui.item.prev()
      next_item = ui.item.next()
      
      # Calculate new order position
      prev_order = if prev_item.length then parseFloat(prev_item.data('order')) else 0
      next_order = if next_item.length then parseFloat(next_item.data('order')) else prev_order + 2
      
      new_order = (prev_order + next_order) / 2
      
      # Update the data-order attribute
      ui.item.data('order', new_order)
      
      # Send AJAX request to update the order
      $.ajax
        url: "/estimations/#{estimation_id}/estimation_items/#{item_id}"
        method: 'PATCH'
        dataType: 'json'
        data:
          estimation_item:
            order: new_order
        error: (xhr, status, error) ->
          console.error('Failed to update order:', error)
          # Revert the sortable on error
          $(this).sortable('cancel')

$(document).ready(activate_sortable)
document.addEventListener('turbo:load', activate_sortable)
document.addEventListener('turbo:render', activate_sortable)

