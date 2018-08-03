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

compile = (fileName, newFileName) ->
    contents = fs.readFileSync(fileName, {encoding: 'utf-8'})

    # TODO: make this MUCH more robust than this!
    # You're basicly just lucky if this works.
    contents = contents.replace /(?<=:\s*)\/(.*)\/(?=\s*(#.*)?$)/mg,
        (str, reg, _) ->
            reg = reg.replace(/\\/g, "\\\\")  # replaces \ by \\
            reg = reg.replace(/'/g, "\\x27")  # replaces quotes by their ascii escape
            # TODO: those should be definable in the file dynamically
            reg = reg.replace(/:α:/g, "A-Za-zα-ωϕ-ϛΓΔΘΛΞΠΣΦΨΩϐϵϑϰϱϝ")
            reg = reg.replace(/:α0:/g, "A-Za-zα-ωϕ-ϛΓΔΘΛΞΠΣΦΨΩϐϵϑϰϱϝ_0-9")
            return "'#{reg}'"
    fs.writeFileSync(newFileName, contents)

# Called directly as a script
if require.main == module
    compileFolder = "./grammars"
    fs.readdir compileFolder, (err, files) ->
        files.forEach (fileName) ->
            newFileName = fileName.replace /\.grammar-cson$/, '.cson'
            if fileName != newFileName  # this is as "grammar-cson" file
                compile(
                    "#{compileFolder}/#{fileName}",
                    "#{compileFolder}/#{newFileName}"
                )
                console.log "compiled #{fileName}"
else
    module.exports.compile = compile


################################################################################
# Test character classes with this:
# ABCDEFGHIJKLMNOPQRSTUVWXYZ
# abcdefghijklmnopqrstuvwxyz
# αβγδεζηθι κλμνξοπρςστυφχψω
#   ΓΔ   Θ   Λ  Ξ Π  Σ  ΦΨ Ω
# ϕϗϖϙϘϚϛ ϐϵϑϰϱ ϝ
