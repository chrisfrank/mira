class app.InputView extends app.View
  events: ->
    @el.addEventListener 'click', @
    @el.addEventListener 'touchmove', @
    document.addEventListener 'datemath', @

  handleEvent: (e) ->
    switch e.type
      when 'click' then @createEntry(e)
      when 'datemath' then @toggle(e)
      when 'touchmove' then @block(e)

  createEntry: (e) ->
    target = e.target
    val = target.getAttribute 'data-val'
    if val?
      document.dispatchEvent new CustomEvent('entry:create', {
        detail:
          answer: parseInt(val)
      })

  toggle: (e) ->
    now = e.detail.now
    prev = e.detail.then
    if now > prev
      @show()
    else
      @hide()

  show: ->
    @el.classList.add('is_visible')
    @el.style.position = 'relative'
    @el.style.opacity = '1'

  hide: ->
    @el.style.position = 'absolute'
    @el.style.opacity = '0'
    @el.addEventListener 'webkitTransitionEnd', (e) =>
      @el.classList.remove('is_visible')
      @el.removeEventListener(e.type, arguments.callee)

  block: (e) ->
    e.preventDefault()

  render: ->
    @el.innerHTML = "
      <div data-val=1 class='button button-yes'>Yes</div>
      <div data-val=0 class='button button-no'>No</div>
    "
