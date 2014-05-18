class app.EntriesCollection
  constructor: ->
    @restore()

  restore: ->
    @records = []
    if localStorage["dailyq:entries"]?
      @records = JSON.parse(localStorage["dailyq:entries"]).map (entry) ->
        new app.Entry(entry)
    @broadcastChange()
    @records

  save: ->
    localStorage["dailyq:entries"] = JSON.stringify @records
    @broadcastChange()
    @records

  add: (entry) ->
    @records.push (entry)
    @save()

  getRecords: -> @records

  reset: ->
    if (confirm('Are you sure you want to permanently delete all entries?'))
      @records = []
      @save()
    else
      return

  seed: ->
    i = 0
    while (i < 20)
      @add new app.Entry({answer: i%2})
      i += 1

  broadcastChange: ->
    document.dispatchEvent new CustomEvent('entries:changed', {
      detail:
        entries: @getRecords()
    })
