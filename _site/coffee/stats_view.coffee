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
