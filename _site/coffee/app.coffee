class app.AppController
  constructor: ->
    document.dispatchEvent new CustomEvent('app:starting')
    app.prompt = "Did you need to be in New York City today?"

    app.views = {
      top: new app.TopView(document.getElementById 'top')
      prompt: new app.PromptView(document.getElementById 'prompt')
      scroller: new app.ScrollView(document.getElementById 'list')
      input: new app.InputView(document.getElementById 'input')
      stats: new app.StatsView(document.getElementById 'stats')
      history: new app.HistoryView(document.getElementById 'history')
      #undo: new app.UndoView(window)
    }
    app.entries = new app.EntriesCollection()
    @listen()
    document.dispatchEvent new CustomEvent('app:loaded')

  listen: ->
    document.addEventListener 'entry:create', (e) ->
      app.entries.add new app.Entry(answer: e.detail.answer)

document.addEventListener 'DOMContentLoaded', ->
  app.controller = new app.AppController
