class app.EntriesCollection
  constructor: ->
    @restore()

  restore: ->
    @records = []
    if localStorage["mira:entries"]?
      @records = JSON.parse(localStorage["mira:entries"]).map (entry) ->
        new app.Entry(entry)
    @broadcastChange()
    @records

  save: ->
    localStorage["mira:entries"] = JSON.stringify @records
    @broadcastChange()
    @records

  add: (entry) ->
    @records.push (entry)
    @save()

  getRecords: -> @records

  reset: ->
    @records = []
    document.dispatchEvent new CustomEvent('entries:reset')
    @save()

  seed: ->
    i = 0
    while (i < 20)
      @add new app.Entry({
        answer: i%2
        date: new Date(1987,0,i)
      })
      i += 1

  broadcastChange: ->
    document.dispatchEvent new CustomEvent('entries:changed', {
      detail:
        entries: @getRecords()
    })
