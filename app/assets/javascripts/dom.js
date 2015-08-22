Element.prototype.remove = function() {
  this.parentElement.removeChild(this);
}

HTMLElement.prototype.highlight = function() {
  this.classList.add('highlight');
  // FIXME There should be a better way of not highlighting all previously triggered elements
  this.addEventListener("animationend", function() {
    this.classList.remove('highlight');
  });
}
