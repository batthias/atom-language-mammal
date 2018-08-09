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

    aliases = {  # in this dictionary we save the aliases
        "\\": "\\\\",  # replace \ by \\
        "'": "\\x27",
    }
    replaceAliases = (text) ->
        for alias, replacement of aliases
            text = text.replace alias, replacement
        return text

    # TODO: make this MUCH more robust than this!
    # You're basicly just lucky if this works.
    # this would be cool but doesn‘t work  /(?<=:\s*)\/(.*)\/(?=\s*(#.*)?$)/mg,
    newContents = ""
    for line in contents.split('\n')
        matchResults = line.match /^\s*#!define (:[^:]+:) = (.*)$/
        if matchResults
            console.log "matched expression", matchResults
            aliases[matchResults[1]] = replaceAliases matchResults[2]
        else
            line = line.replace /(:\s*)\/(.*)\/(?=\s*(#.*)?$)/mg,
                (str, colon, reg, _) -> "#{colon}'#{replaceAliases reg}'"
            newContents += "#{line}\n"
    fs.writeFileSync(newFileName, newContents)

compileFolder = (folder) ->
    fs.readdir folder, (err, files) ->
        console.log err
        if not files then return
        files.forEach (fileName) ->
            newFileName = fileName.replace /\.grammar-cson$/, '.cson'
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
