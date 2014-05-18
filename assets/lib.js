
(function(global){
  var scrollHack = {
    supported: typeof global.getComputedStyle(document.createElement('div'))['-webkit-overflow-scrolling'] !== 'undefined',
    enable: function(){
      document.addEventListener('touchstart', this, false)
    },
    handleEvent: function(e) {
      switch(e.type) {
        case "touchstart":
          this.ontouchstart(e);
          break;
      }
    },
    ontouchstart: function(e) {
      el = e.target
      while (el != document.body) {
        var style = global.getComputedStyle(el)
        var scrolling = style.getPropertyValue('-webkit-overflow-scrolling')
        var overflow = style.getPropertyValue('overflow')
        var height = el.getBoundingClientRect().height
        var canScroll = scrolling === 'touch' && overflow === 'auto'
        if (canScroll) {
          var isAtTop = (el.scrollTop === 0)
          var isAtBottom = (el.scrollHeight - el.scrollTop === height)
          if (isAtTop || isAtBottom) {
            // if the content is too short, put it all in a tall div
            if (el.scrollHeight <= height){
              scrollPad = document.createElement('div')
              scrollPad.style.minHeight = '100%'
              scrollPad.style.paddingBottom = '2px'
              scrollPad.innerHTML = el.innerHTML
              el.innerHTML = ''
              el.appendChild(scrollPad)
            }
            // adjust the scroll position by one pixel, which bypasses
            // the scroll bounce on the document body
            if (isAtTop) {
              el.scrollTop += 1;
            } else if (isAtBottom) {
              el.scrollTop -=1;
            }
            return
          }
        }
        el = el.parentNode
      }
    }
  }
  if (!!scrollHack.supported) {
    scrollHack.enable()
  }
})(this)
