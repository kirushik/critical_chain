Element.prototype.remove = function() {
  this.parentElement.removeChild(this);
}

HTMLElement.prototype.highlight = function() {
  this.classList.add('highlight');
}
