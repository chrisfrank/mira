class app.UndoView extends app.View
  events: ->
    window.addEventListener 'shake', @
    document.addEventListener 'entry:create', @

  handleEvent: (e) ->
    @enable() if e.type == 'entry:create'
    @undo() if e.type == 'shake'

  enable: ->
    @enabled = true

  undo: ->
    return unless @enabled
    if confirm('Undo entry?')
      document.dispatchEvent new CustomEvent('entry:undo')
      @enabled = false
