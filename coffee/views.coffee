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

class app.TogglingView extends app.View
  events: ->
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()
    document.addEventListener 'entries:changed', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'

  onEntryChange: (e) ->
    entries = e.detail.entries.slice(0)
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
    @rerender(e) if e.type == 'entries:changed'
    super

  toggle: (now, previously) ->
    if (now <= previously) then @show() else @hide()

  rerender: (e) ->
    @entries = e.detail.entries
    @yeas = @entries.filter (entry) -> entry.answer == 1
    @nays = @entries.filter (entry) -> entry.answer == 0
    yesPct = Math.floor(@yeas.length / @entries.length * 100)
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
    @el.addEventListener 'touchstart', @

  handleEvent: (e) ->
    @onTouchStart(e) if e.type == 'touchstart'

  onTouchStart: (e) ->
    height = @el.getBoundingClientRect().height
    atTop = @el.scrollTop == 0
    atBottom = (@el.scrollHeight - @el.scrollTop == height)
    @el.scrollTop += 1 if atTop
    @el.scrollTop -=1 if atBottom


class app.HistoryView extends app.View
  initialize: ->
    @months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  events: ->
    document.addEventListener 'entries:changed', @
    document.addEventListener 'toggling_view:shown', @
    document.addEventListener 'topview:height', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'
    @adjustHeight(e) if e.type == 'topview:height'

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

  adjustHeight: (e) ->
    offset = e.detail.height
    @el.style.top = offset + 'px' if offset?


class app.TopView extends app.View
  events: ->
    document.addEventListener 'toggling_view:shown', @
    window.addEventListener 'orientationchange', @
  handleEvent: () ->
    @sendHeight()
  sendHeight: (e) ->
    console.log @el.getBoundingClientRect()
    document.dispatchEvent new CustomEvent('topview:height', {
      detail:
        height: @el.offsetHeight
    })

