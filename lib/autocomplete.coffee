module.exports.provider =
   # In Mammal, but not in comments
  selector: '.source.mammal'
  disableForSelector: '.source.mammal .comment'

  # This will take priority over the default provider, which has a inclusionPriority of 0.
  # `excludeLowerPriority` will suppress any providers with a lower priority
  # i.e. The default provider will be suppressed
  inclusionPriority: 1
  excludeLowerPriority: true

  # This will be suggested before the default provider, which has a suggestionPriority of 1.
  suggestionPriority: 2

  # Return a promise, an array of suggestions, or null.
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    # Find your suggestions here
    self = @
    nPrefix = @getNumberPrefix(editor, bufferPosition)
    console.log "#{scopeDescriptor} at #{bufferPosition} with prefixes: '#{prefix}', '#{nPrefix}'"

    # Scientific notation
    if res = prefix.match(/^(\d+)(e|E|ten)([+-−]?\d+)$/)
      return new Promise (resolve) ->
        [match, base, sep, exponent] = res
        sep =  if sep == 'ten' then '⋅10^' else 'ᴇ'
        suggestion =
          text: "#{base}#{sep}#{exponent}"
          leftLabel: sep
          description: 'scientific notation float' # (optional)
          descriptionMoreURL: '' # (optional)
        resolve([suggestion])

    # Expontents
    if res = nPrefix.match(/^\^\s*([-−+0-9]+)$/)
      return new Promise (resolve) ->
        [match, exponent] = res
        suggestion =
          text: "#{self.raiseLetters(exponent)}"
          replacementPrefix: nPrefix
        resolve([suggestion])


  raiseLetters: (str) ->
    chars  = "0123456789+-−"
    raised = "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁻"
    res = ""
    for c, i in str
      res += raised[chars.indexOf(c)]
    return res


  getNumberPrefix: (editor, bufferPosition) ->
    regex = /[+−^*\/-]\s*[+-−0-9]+$/
    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

    # Match the regex to the line, and return the match
    return line.match(regex)?[0] or ''

  # (optional): called _after_ the suggestion `replacementPrefix` is replaced
  # by the suggestion `text` in the buffer
  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  # (optional): called when your provider needs to be cleaned up. Unsubscribe
  # from things, kill any processes, etc.
  dispose: ->
