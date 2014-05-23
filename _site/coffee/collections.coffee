class app.EntriesCollection
  constructor: ->
    @restore()
    @events()

  events: ->
    document.addEventListener 'entry:undo', @
    document.addEventListener 'question:changed', @

  handleEvent: (e) ->
    @pop() if e.type == 'entry:undo'
    @reset() if e.type == 'question:changed'

  restore: ->
    @records = []
    if localStorage["mira:entries"]?
      @records = JSON.parse(localStorage["mira:entries"]).map (entry) ->
        new app.Entry(entry)
    @broadcastChange()
    @records

  save: ->
    localStorage["mira:entries"] = JSON.stringify @records
    @records

  add: (entry) ->
    @records.push (entry)
    document.dispatchEvent new CustomEvent('entry:added', {
      detail:
        collection: @
        entry: entry
    })
    @save()

  pop: ->
    entry = @records.pop()
    @save()
    document.dispatchEvent new CustomEvent('entry:removed', {
      detail:
        collection: @
        entry: entry
    })
    entry

  getRecords: -> @records.slice(0)

  reset: ->
    @records = []
    document.dispatchEvent new CustomEvent('entries:reset')
    @save()
    @broadcastChange()

  seed: ->
    i = 0
    while (i < 20)
      @add new app.Entry({
        answer: 1
        date: new Date(1987,0,i)
      })
      i += 1

  broadcastChange: ->
    document.dispatchEvent new CustomEvent('entries:changed', {
      detail:
        collection: @
    })
