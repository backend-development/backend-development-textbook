
"use strict";

window.addEventListener("load", function() {
  var clipboard = new ClipboardJS('.clipboard-button');
  clipboard.on('success', function(e) {
    var trigger = e.trigger;
    var triggerLabel = trigger.innerHTML;
    trigger.innerHTML = 'Copied!';
    setTimeout(function(){
      trigger.innerHTML = triggerLabel;
    }, 3000);
    e.clearSelection();
  });
});
