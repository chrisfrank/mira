class app.PromptView extends app.View
  events: ->
    @el.addEventListener 'click', @
    @el.addEventListener 'touchmove', (e) -> e.preventDefault()
    document.addEventListener 'question:changed', @
    document.addEventListener 'question:restored', @
  handleEvent: (e) ->
    @newQuestion() if e.type == 'click'
    @rerender(e) if e.type.match(/question/i)
  rerender: (e) ->
    q = e.detail.question
    @el.innerHTML = "<h1>#{ q }</h1>"
    if q.length > 60
      @el.classList.add 'long'
    else
      @el.classList.remove 'long'
  newQuestion: ->
    q = prompt "Ask a new question:"
    if q? && q.length > 0
      document.dispatchEvent new CustomEvent('question:change', {
        detail:
          question: q
      })

