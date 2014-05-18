class app.AppController
  constructor: ->
    document.dispatchEvent new CustomEvent('app:starting')
    app.prompt = "Did you need to be in New York City today?"

    app.views = {
      prompt: new app.PromptView(document.getElementById 'prompt')
      scroller: new app.ScrollView(document.getElementById 'list')
      input: new app.InputView(document.getElementById 'input')
      stats: new app.StatsView(document.getElementById 'stats')
      history: new app.HistoryView(document.getElementById 'history')
    }
    app.entries = new app.EntriesCollection()
    @listen()
    lastEntry = app.entries.getRecords().pop()
    if lastEntry
      lastDate = new Date(lastEntry.date).setHours(0,0,0,0)
      now = new Date().setHours(0,0,0,0)
      if now > lastEntry
        app.views.input.show()
      else
        app.views.stats.show()
    else
      app.views.input.show()
    document.dispatchEvent new CustomEvent('app:loaded')

  listen: ->
    document.addEventListener 'entry:create', (e) ->
      app.entries.add new app.Entry(answer: e.detail.answer)

document.addEventListener 'DOMContentLoaded', ->
  app.controller = new app.AppController
