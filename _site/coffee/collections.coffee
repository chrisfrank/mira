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
    @broadcastChange()
    @records

  add: (entry) ->
    @records.push (entry)
    @save()

  pop: ->
    entry = @records.pop()
    @save()
    entry

  getRecords: -> @records.slice(0)

  reset: ->
    @records = []
    document.dispatchEvent new CustomEvent('entries:reset')
    @save()

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
