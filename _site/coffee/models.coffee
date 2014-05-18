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



