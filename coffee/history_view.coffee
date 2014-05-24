class app.HistoryView extends app.View
  initialize: ->
    @fragment = document.createDocumentFragment()
    @months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

  events: ->
    document.addEventListener 'entries:changed', @

  handleEvent: (e) ->
    @onEntryChange(e) if e.type == 'entries:changed'

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
