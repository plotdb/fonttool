require! <[fs opentype.js]>

filename = process.argv.2
if !filename =>
  console.log "usage: lsc missing.ls <font-filename>"
  process.exit -1

chars = fs.read-file-sync 'word-frequency.csv'
  .toString!
  .split \\n
  .map -> it.trim!
  .filter -> it and it.length
  .map -> it.split(\,)
chars.splice 0, 1

opentype.load filename, (e, font) ->
  glyphs = font.glyphs.glyphs
  list = []
  [0 til font.glyphs.length]
    .map(-> glyphs[it])
    .filter(->it and it.unicode and it.xMax)
    .map -> list ++= it.unicodes
  missing = []
  for char in chars =>
    if !(char.0.charCodeAt(0) in list) => missing.push char.0
  console.log "for chars in word-frequency: "
  console.log "total #{chars.length} characters."
  console.log " - #{chars.length - missing.length} chars found corresponding glyphs."
  console.log " - #{missing.length} missing glyphs."
  console.log "missing chars: "
  console.log missing.join('')
