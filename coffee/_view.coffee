class app.View
  constructor: (el) ->
    throw "Cannot construct view without an HTML element"  unless el?
    @el = el
    @initialize()
    @render()
    @events()

  initialize: ->
  render: ->
  events: ->
