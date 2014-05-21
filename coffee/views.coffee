Node.prototype.prependChild = (el) ->
  this.childNodes[0]&&this.insertBefore(el, this.childNodes[0]) || this.appendChild(el)

class app.View
  constructor: (el) ->
    throw "Cannot construct view without an HTML element"  unless el?
    @el = el
    @initialize()
    @render()
    @events()

  initialize: ->
  render: ->
  events: ->

class app.PromptView extends app.View
  events: ->
    @el.addEventListener 'click', @
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()
    @el.addEventListener 'touchstart', @, false
    document.addEventListener 'question:changed', @
    document.addEventListener 'question:restored', @
  handleEvent: (e) ->
    e.preventDefault() if e.type == 'click'
    @newQuestion() if e.type == 'touchstart'
    @rerender(e) if e.type.match(/question/i)
  rerender: (e) ->
    q = e.detail.question
    @el.innerHTML = "<h1>#{ q }</h1>"
    if q.length > 60
      @el.classList.add 'long'
    else
      @el.classList.remove 'long'
  newQuestion: ->
    q = prompt "Ask a new question:"
    if q? && q.length > 0
      document.dispatchEvent new CustomEvent('question:change', {
        detail:
          question: q
      })

class app.TogglingView extends app.View
  events: ->
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()
    document.addEventListener 'entries:changed', @
    document.addEventListener 'entry:added', @
    document.addEventListener 'entry:removed', @

  handleEvent: (e) ->
    @onEntryChange(e)

  onEntryChange: (e) ->
    entries = e.detail.collection?.getRecords()
    if entries?
      lastEntry = entries.pop()
      lastDate = new Date(lastEntry?.date).setHours(0,0,0,0) || 0
      now = new Date().setHours(0,0,0,0)
      @toggle(now, lastDate)

  toggle: (now, previously) ->
    if (now > previously) then @show() else @hide()

  hide: ->
    @el.style.opacity = '0'
    @el.style.zIndex = 0
    document.dispatchEvent new CustomEvent 'toggling_view:shown'

  show: ->
    @el.style.opacity = '1'
    @el.style.zIndex = 1
    document.dispatchEvent new CustomEvent 'toggling_view:shown'

class app.StatsView extends app.TogglingView

  handleEvent: (e) ->
    @rerender(e) if e.type == 'entries:changed' || e.type == 'entry:added'
    super

  toggle: (now, previously) ->
    if (now <= previously) then @show() else @hide()

  rerender: (e) ->
    entries = e.detail.collection.getRecords()
    @yeas = entries.filter (entry) -> entry.answer == 1
    @nays = entries.filter (entry) -> entry.answer == 0
    yesPct = Math.floor(@yeas.length / entries.length * 100)
    noPct = 100 - yesPct
    @el.innerHTML = "
      <div class='percentages'>
        <div class='percentage percentage-yes' style='width: #{yesPct}%'></div>
        <div class='percentage percentage-no' style='width: #{noPct}%'></div>
      </div>
    "

class app.InputView extends app.TogglingView
  events: ->
    @el.addEventListener app.CLICK_EVENT, @
    super

  handleEvent: (e) ->
    @newEntry(e) if e.type == app.CLICK_EVENT
    super

  newEntry: (e) ->
    target = e.target
    val = target.getAttribute 'data-val'
    if val?
      document.dispatchEvent new CustomEvent('entry:create', {
        detail:
          answer: parseInt(val)
      })

  render: ->
    @el.innerHTML = "
      <div data-val=1 class='button button-yes'>Yes</div>
      <div data-val=0 class='button button-no'>No</div>
    "

class app.ScrollView extends app.View
  events: ->
    window.addEventListener 'resize', @
    @el.addEventListener 'touchstart', @

  handleEvent: (e) ->
    @onTouchStart(e) if e.type == 'touchstart'

  onTouchStart: (e) ->
    height = @el.getBoundingClientRect().height
    atTop = @el.scrollTop <= 0
    atBottom = (@el.scrollHeight - @el.scrollTop >= height)
    if atTop
      @el.scrollTop = 1
    else if atBottom
      @el.scrollTop = @el.scrollHeight - height - 1


class app.HistoryView extends app.View
  initialize: ->
    @fragment = document.createDocumentFragment()
    @months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  events: ->
    document.addEventListener 'entries:changed', @
    document.addEventListener 'entry:added', @
    document.addEventListener 'entry:removed', @
    document.addEventListener 'topview:height', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'
    @adjustHeight(e) if e.type == 'topview:height'
    @addEntry(e) if e.type == 'entry:added'
    @removeEntry(e) if e.type == 'entry:removed'

  onEntryChange: (event) ->
    @entries = event.detail.collection.getRecords()
    @render()

  render: ->
    @fragment = document.createDocumentFragment()
    @el.innerHTML = ''
    if @entries?
      @renderEntry(entry) for entry in @entries.reverse()
    @el.appendChild @fragment

  renderEntry: (entry) ->
    date = new Date(entry.date)
    elem = document.createElement 'div'
    elem.className = "entry entry-#{ entry.answer }"
    elem.id = "entry_#{ entry.date }"
    elem.innerHTML = "<div class='entry_date'>
        #{@months[date.getMonth()]}
        #{date.getDate()}
      </div>
      <div class='entry_answer'></div>
    "
    @fragment.appendChild elem

  adjustHeight: (e) ->
    offset = e.detail.height
    @el.style.top = offset + 'px' if offset?

  addEntry: (e) ->
    entry = e.detail.entry
    @fragment = document.createDocumentFragment()
    @renderEntry(entry)
    @el.prependChild @fragment
    @el.style.webkitTransition = 'none'
    @el.style.webkitTransform = 'translate3d(0,-63px,0)'
    setTimeout () =>
      @el.style.webkitTransition = '-webkit-transform .5s'
      @el.style.webkitTransform = 'translate3d(0,0,0)'
      @el.addEventListener 'webkitTransitionEnd', (e) =>
        @el.style.webkitTransition = @el.style.webkitTransform = null
        @el.removeEventListener 'webkitTransitionEnd', arguments.callee
    , 1

  removeEntry: (e) ->
    entry = e.detail.entry
    elem = document.getElementById("entry_#{entry.date}")
    @el.style.webkitTransition = 'none'
    setTimeout () =>
      @el.style.webkitTransition = '-webkit-transform .25s'
      @el.style.webkitTransform = 'translate3d(0,-63px,0)'
      @el.addEventListener 'webkitTransitionEnd', (e) =>
        @el.style.webkitTransition = @el.style.webkitTransform = null
        @el.removeEventListener 'webkitTransitionEnd', arguments.callee
        elem?.parentNode.removeChild(elem)
    , 1


class app.TopView extends app.View
  events: ->
    document.addEventListener 'toggling_view:shown', @
    window.addEventListener 'orientationchange', @
    document.addEventListener 'question:changed', @
    document.addEventListener 'question:restored', @
  handleEvent: () ->
    @sendHeight()
  sendHeight: (e) ->
    document.dispatchEvent new CustomEvent('topview:height', {
      detail:
        height: @el.offsetHeight
    })

class app.UndoView extends app.View
  events: ->
    window.addEventListener 'shake', @
    document.addEventListener 'entry:added', @

  handleEvent: (e) ->
    @enable() if e.type == 'entry:added'
    @undo() if e.type == 'shake'

  enable: ->
    @enabled = true

  undo: ->
    return unless @enabled
    if confirm('Undo entry?')
      document.dispatchEvent new CustomEvent('entry:undo')
      @enabled = false
