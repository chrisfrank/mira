class app.DateMathView extends app.View
  events: ->
    document.addEventListener 'entries:changed', @

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

