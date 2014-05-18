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
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()
  render: ->
    @el.innerHTML = "<h1>#{ app.prompt }</h1>"

class app.InputView extends app.View
  events: ->
    document.addEventListener 'entry:create', @
    @el.addEventListener app.CLICK_EVENT, @
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()

  handleEvent: (e) ->
    @newEntry(e) if e.type == app.CLICK_EVENT
    @hide(e) if e.type == 'entry:create'


  newEntry: (e) ->
    target = e.target
    val = target.getAttribute 'data-val'
    if val?
      document.dispatchEvent new CustomEvent('entry:create', {
        detail:
          answer: parseInt(val)
      })

  hide: ->
    @el.style.display = 'none'

  render: ->
    @el.innerHTML = "
      <div data-val=1 class='button button-yes'>Yes</div>
      <div data-val=0 class='button button-no'>No</div>
    "

class app.ScrollView extends app.View
  events: ->
    @el.addEventListener 'touchstart', @

  handleEvent: (e) ->
    @onTouchStart(e) if e.type == 'touchstart'

  onTouchStart: (e) ->
    height = @el.getBoundingClientRect().height
    atTop = @el.scrollTop == 0
    atBottom = @el.scrollHeight = - @el.scrollTop == height
    @el.scrollTop += 1 if atTop
    @el.scrollTop -=1 if atBottom


class app.HistoryView extends app.View
  initialize: ->
    @months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  events: ->
    document.addEventListener 'entries:changed', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'

  onEntryChange: (event) ->
    @entries = event.detail.entries
    @render()

  render: ->
    @el.innerHTML = ''
    if @entries?
      @renderEntry(entry) for entry in @entries

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
    @el.prependChild elem

class app.StatsView
  constructor: (el) ->
    throw "Cannot construct view without an HTML element"  unless el?
    @el = el
    @events()
  events: ->
    document.addEventListener 'entry:create', @
    document.addEventListener 'entries:changed', @

  handleEvent: (e) ->
    @show() if e.type == 'entry:create'
    @render(e) if e.type == 'entries:changed'

  show: ->
    @el.style.display = 'block'

  render: (e) ->
    @entries = e.detail.entries
    @el.innerHTML = @entries.length

