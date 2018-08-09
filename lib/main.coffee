# Provide the autocompletion Tool
path = require('path')
{CompositeDisposable} = require 'atom'
{compileFolder} = require './grammar-cson-compiler'

module.exports =
  provide: ->
    require('./autocomplete').provider
  activate: ->
    console.log "Activated Mammal"
    @subscriptions = new CompositeDisposable();
    @subscriptions.add atom.commands.add 'atom-workspace',
      'language-mammal:compile-grammar-csons': (event) ->
          console.log "compiling folder"
          compileFolder path.join __dirname, "..", "grammars"



# atom.commands.add 'atom-workspace',
#   'language-mammal:compile-grammar-csons': (event) ->
#    module.exports.compileGrammarCsons()
