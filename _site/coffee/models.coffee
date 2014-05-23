class app.Entry
  constructor: (args) ->
    args ||= {}
    args.date ||= Date.now()
    throw "Can't create entry without answer" unless args.answer == 1 || args.answer == 0
    @setDate args.date
    @setAnswer args.answer

  getDate: () -> @date
  setDate: (date) -> @date = date
  getAnswer: () -> @answer
  setAnswer: (answer) -> @answer = answer
  getAttributes: ->
    {
      date: @getDate()
      answer: @getAnswer()
    }

class app.Question
  constructor: ->
    @q = localStorage['mira:question'] || "If today were the last day of your life, would you want to do what you're about to do?"
    @events()
    document.dispatchEvent new CustomEvent('question:restored', {
      detail:
        question: @q
    })

  events: ->
    document.addEventListener 'question:change', @

  handleEvent: (e) ->
    @changeQuestion(e.detail.question)

  changeQuestion: (q) ->
    return unless q?
    @q = localStorage['mira:question'] = q
    @broadcastQuestion()

  broadcastQuestion: ->
    document.dispatchEvent new CustomEvent('question:changed', {
      detail:
        question: @q
    })

