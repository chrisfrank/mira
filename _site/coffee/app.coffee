class app.AppController
  constructor: ->
    document.dispatchEvent new CustomEvent('app:starting')

    app.views = {
      prompt: new app.PromptView(document.getElementById 'prompt')
      scroller: new app.ScrollView(document.getElementById 'list')
      toggle: new app.TogglingView(document.createElement('div'))
      history: new app.HistoryView(document.getElementById 'history')
      input: new app.InputView(document.getElementById 'input')
      stats: new app.StatsView(document.getElementById 'stats')
      undo: new app.UndoView(window)
      top: new app.TopView(document.getElementById 'top')
    }

    app.entries = new app.EntriesCollection()
    app.question = new app.Question()
    @listen()
    document.dispatchEvent new CustomEvent('app:loaded')

  listen: ->
    document.addEventListener 'entry:create', (e) ->
      app.entries.add new app.Entry(answer: e.detail.answer)

document.addEventListener 'DOMContentLoaded', ->
  app.controller = new app.AppController
  FastClick.attach(document.body)
