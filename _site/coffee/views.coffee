Node.prototype.prependChild = (el) ->
  this.childNodes[0]&&this.insertBefore(el, this.childNodes[0]) || this.appendChild(el)

class app.View
  constructor: (el) ->
    throw "Cannot construct view without an HTML element"  unless el?
    @el = el
    @render()
    @events()

  render: ->
  events: ->

class app.PromptView extends app.View
  render: ->
    @el.innerHTML = "<h1>#{ app.prompt }</h1>"

class app.InputView extends app.View
  events: ->
    @el.addEventListener 'click', @newEntry

  newEntry: (e) ->
    target = e.target
    val = parseInt(target.getAttribute 'data-val')
    document.dispatchEvent new CustomEvent('entry:create', {
      detail:
        answer: val
    })

  render: ->
    @el.innerHTML = "
      <div data-val=0 class='button button-no'>No</div>
      <div data-val=1 class='button button-yes'>Yes</div>
    "


class app.HistoryView extends app.View
  events: ->
    document.addEventListener 'entries:changed', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'

  onEntryChange: (event) ->
    console.log 'changed!'
    @entries = event.detail.entries
    @render()

  render: ->
    if @entries?
      @renderEntry(entry) for entry in @entries

  renderEntry: (entry) ->
    elem = document.createElement 'div'
    elem.className = "entry entry_#{ entry.answer }"
    elem.id = "entry_#{ entry.date }"
    elem.innerHTML = entry.date
    @el.prependChild elem unless document.getElementById(elem.id)?

class app.StatsView
