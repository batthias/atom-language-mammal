# Provide the autocompletion Tool
path = require('path')
{CompositeDisposable} = require 'atom'
{compileFolder} = require

module.exports =
  activate: ->
    console.log "Activated Mammal"
    @subscriptions = new CompositeDisposable();
    @subscriptions.add atom.commands.add 'atom-workspace',
      'language-mammal:compile-grammar-csons': (event) ->
          @compileGrammarCsons
    @subscriptions.add atom.commands.add 'atom-workspace',
      'language-mammal:compile-grammar-csons-and-reload': (event) ->
          @compileGrammarCsons
          @reload

    @subscriptions.add atom.commands.add 'atom-workspace',
      'language-mammal:activate-developer-mode': (event) ->
          @activateDeveloperMode

    return unless atom.inDevMode() && !atom.inSpecMode()
    atom.workspace.observeTextEditors (editor) =>
      editor.buffer.onDidSave =>
        @reload()

  deactivate: ->
      @statusBarTile?.destroy()  # free the status bar tile
      @statusBarTile = null

  consumeStatusBar: (statusBar) ->  # Use the status bar to display stuff
    tile = document.createElement('div')
    @statusBarTile = statusBar.addRightTile tile

  activateDeveloperMode: ->
    console.log "Activated developer mode"


  provide: ->
    require('./autocomplete').provider

  compileGrammarCsons: ->
    require('./grammar-cson-compiler').compileFolder path.join __dirname, "..", "grammars"

  reload: ->
    # return unless atom.config.get("#{pkg.name}.enabled")
    pkgPath = path.join(atom.project.rootDirectories[0].path, 'package.json')
    if atom.project.contains(pkgPath)
      projectPkg = require(pkgPath)
      if projectPkg.engines? && projectPkg.engines.atom?
        for g in atom.grammars.grammars
          if (g?.packageName == projectPkg.name)
            atom.grammars.removeGrammar g

        delete atom.packages.loadedPackages[projectPkg.name] # force reload
        updatedPackage = atom.packages.loadPackage(projectPkg.name)
        updatedPackage.loadGrammarsSync()
        updatedPackage.grammars.forEach (g) ->
          atom.grammars.addGrammar g

        atom.workspace.observeTextEditors (editor) ->
          if editor.getGrammar().packageName == projectPkg.name
editor.reloadGrammar()


# atom.commands.add 'atom-workspace',
#   'language-mammal:compile-grammar-csons': (event) ->
#    module.exports.compileGrammarCsons()
