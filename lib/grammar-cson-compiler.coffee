# I am really annoyed with how CSON-files don't support the regex-syntax
# from coffeescript:
# I propose the following to be possible syntax:

exampleCsonFile =
    'firstLineMatch': /^#!.*\bpython\b/
    'patterns': []

# See, how this example is not a comment, but code?
# That's because this is already correct coffeescript!
# Why oh, why does CSON not support this as a type? It is a really common one!

# Until this is supported (or raw strings for that matter) this compiler will
# have to be used to create the ".cson"-file for all ".grammar-cson"-files in
# the folder.

################################################################################
fs = require('fs')
path = require('path')


compile = (fileName, newFileName) ->
    contents = fs.readFileSync(fileName, {encoding: 'utf-8'})

    aliases = new Map();  # in this dictionary we save the aliases
    aliases.set /\\/g, "\\\\"  # replace \ by \\
    aliases.set /'/g, "\\x27"

    replaceAliases = (text) ->
        aliases.forEach (replacement, alias) ->
            text = text.replace alias, replacement
        return text

    # TODO: make this MUCH more robust than this!
    # You're basicly just lucky if this works.
    # this would be cool but doesn‘t work  /(?<=:\s*)\/(.*)\/(?=\s*(#.*)?$)/mg,

    newContents = ""
    for line in contents.split('\n')
        matchResults = line.match /^\s*#!define (:[^:]+:) = (.*)\r?$/
        if matchResults
            aliases.set RegExp(matchResults[1], 'g'), replaceAliases matchResults[2]
        else
            line = line.replace /(:\s*)\/(.*)\/(?=\s*(#.*)?\r?$)/,
                (str, colon, reg, _) -> "#{colon}'#{replaceAliases reg}'"
            newContents += "#{line}\n"
    fs.writeFileSync(newFileName, newContents)

compileFolder = (folder) ->
    fs.readdir folder, (err, files) ->
        console.log err
        if not files then return
        files.forEach (fileName) ->
            console.log 'filename =', fileName
            newFileName = fileName.replace /\.grammar-cson$/mg, '.cson'
            if fileName != newFileName  # this is as "grammar-cson" file
                compile(
                    "#{folder}/#{fileName}",
                    "#{folder}/#{newFileName}"
                )
                console.log "compiled #{fileName}"

# Called directly as a script
if require.main == module
    compileFolder path.join __dirname, "..", "grammars"
else
    module.exports =
        compile: compile
        compileFolder: compileFolder


################################################################################
# Test character classes with this:
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
# abcdefghijklmnopqrstuvwxyz
# αβγδεζηθι κλμνξοπρςστυφχψω
#   ΓΔ   Θ   Λ  Ξ Π  Σ  ΦΨ Ω
# ϕϗϖϙϘϚϛ ϐϵϑϰϱ ϝ
