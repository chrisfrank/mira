class app.ScrollView extends app.View
  events: ->
    @el.addEventListener 'touchstart', @

  handleEvent: (e) ->
    @onTouchStart(e) if e.type == 'touchstart'

  onTouchStart: (e) ->
    height = @el.getBoundingClientRect().height
    atTop = @el.scrollTop == 0
    atBottom = (@el.scrollHeight - @el.scrollTop == height)
    if atTop
      #@el.scrollTop = 1
      @el.scrollTop += 1
    else if atBottom
      #@el.scrollTop = @el.scrollHeight - height - 1
      @el.scrollTop -= 1

