/*!
Deck JS - deck.escape - v1.0
Copyright (c) 2013 Brigitte Jellinek
*/

/*
This module adds the necessary methods and key bindings to 
escape from a slide.  Built for http://web-development.github.com/
*/
(function($, deck, undefined) {
  var $d = $(document);
  
  /*
  Extends defaults/options.
  
  options.gotodelay
          The time in milliseconds to wait between key presses before jumping to a slide.
  */
  $.extend(true, $[deck].defaults, {
          gotodelay: 300
  });
  
  $d.bind('deck.init', function() {
    // Bind key events
    $d.unbind('keydown.escape').bind('keydown.escape', function(e) {
      delay = $[deck]('getOptions').gotodelay;
      
      if (e.which == 27) {
        e.preventDefault();
        var before = document.location, 
            after = new String(before);
            
        after = after.replace("slides_", "");
        console.log("escaping from " + before + " to " + after);

        document.location = after;
      }
    });
  });
})(jQuery, 'deck');

