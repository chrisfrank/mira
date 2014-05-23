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
    document.addEventListener 'question:changed', @
    document.addEventListener 'question:restored', @
  handleEvent: (e) ->
    @newQuestion() if e.type == 'click'
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
    document.addEventListener 'entries:changed', @
    document.addEventListener 'entry:removed', @
    document.addEventListener 'entry:added', @

  handleEvent: (e) ->
    @onEntryChange(e)

  onEntryChange: (e) ->
    entries = e.detail.collection?.getRecords()
    if entries?
      lastEntry = entries.pop()
      lastDate = new Date(lastEntry?.date).setHours(0,0,0,0) || 0
      now = new Date().setHours(0,0,0,0)
      @broadcastDate(now, lastDate)

  broadcastDate: (now, lastDate) ->
    document.dispatchEvent new CustomEvent('datemath', {
      detail:
        now: now
        then: lastDate
    })

class app.StatsView extends app.View
  events: ->
    document.addEventListener 'entries:changed', @
    document.addEventListener 'entry:added', @
    document.addEventListener 'datemath', @

  handleEvent: (e) ->
    if e.type == 'datemath'
      now = e.detail.now
      prev = e.detail.then
      if now <= prev
        @show()
      else
        @hide()
    else
      entries = e.detail.collection.getRecords()
      @yeas = entries.filter (entry) -> entry.answer == 1
      @nays = entries.filter (entry) -> entry.answer == 0
      yesPct = Math.floor(@yeas.length / entries.length * 100)
      noPct = 100 - yesPct
      @el.innerHTML = "
        <div class='percentages'>
          <div data-pct='#{yesPct}%' class='percentage percentage-yes' style='width: #{yesPct}%'></div>
          <div data-pct='#{noPct}%' class='percentage percentage-no' style='width: #{noPct}%'></div>
        </div>
      "
  show: ->
    @el.style.display = 'block'

  hide: ->
    @el.style.display = 'none'

class app.InputView extends app.View
  events: ->
    @el.addEventListener 'click', @
    document.addEventListener 'datemath', @

  handleEvent: (e) ->
    if e.type == 'click'
      target = e.target
      val = target.getAttribute 'data-val'
      if val?
        document.dispatchEvent new CustomEvent('entry:create', {
          detail:
            answer: parseInt(val)
        })
    else if e.type == 'datemath'
      now = e.detail.now
      prev = e.detail.then
      if now > prev
        @show()
      else
        @hide()
  show: ->
    @el.classList.add('is_visible')
    @el.style.position = 'relative'
    @el.style.webkitTransform = 'scaleY(1)'
    @el.style.opacity = '1'
    document.dispatchEvent new CustomEvent 'toggling_view:toggled'

  hide: ->
    @el.style.position = 'absolute'
    document.dispatchEvent new CustomEvent 'toggling_view:toggled'
    @el.style.webkitTransform = 'scaleY(0.4)'
    @el.style.opacity = '0'
    @el.addEventListener 'webkitTransitionEnd', (e) =>
      @el.classList.remove('is_visible')
      @el.removeEventListener(e.type, arguments.callee)


  render: ->
    @el.innerHTML = "
      <div data-val=1 class='button button-yes'>Yes</div>
      <div data-val=0 class='button button-no'>No</div>
    "

class app.ScrollView extends app.View
  events: ->
    @el.addEventListener 'touchstart', @
    document.addEventListener 'topview:height', @

  handleEvent: (e) ->
    @onTouchStart(e) if e.type == 'touchstart'
    @adjustHeight(e) if e.type == 'topview:height'

  onTouchStart: (e) ->
    height = @el.getBoundingClientRect().height
    atTop = @el.scrollTop <= 0
    atBottom = (@el.scrollHeight - @el.scrollTop >= height)
    if atTop
      @el.scrollTop = 1
    else if atBottom
      @el.scrollTop = @el.scrollHeight - height - 1

  adjustHeight: (e) ->
    offset = e.detail.height
    @el.style.top = offset + 'px' if offset?


class app.HistoryView extends app.View
  initialize: ->
    @fragment = document.createDocumentFragment()
    @months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  events: ->
    document.addEventListener 'entries:changed', @
    document.addEventListener 'entry:added', @
    document.addEventListener 'entry:removed', @
    document.addEventListener 'datemath', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'
    @addEntry(e) if e.type == 'entry:added'
    @removeEntry(e) if e.type == 'entry:removed'
    @adjustOffset(e) if e.type == 'datemath'

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


  addEntry: (e) ->
    entry = e.detail.entry
    @fragment = document.createDocumentFragment()
    @renderEntry(entry)
    @el.prependChild @fragment

  removeEntry: (e) ->
    entry = e.detail.entry
    elem = document.getElementById("entry_#{entry.date}")
    elem?.parentNode.removeChild(elem)

  adjustOffset: (e) ->
    now = e.detail.now
    prev = e.detail.then
    if now > prev
      @el.style.top = '0'
    else
      @el.style.top = '41px'


class app.TopView extends app.View
  events: ->
    document.addEventListener 'toggling_view:toggled', @
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
