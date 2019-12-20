require! <[fs path fs-extra fontmin gulp-rename]>

fontfile = process.argv.2
code = process.argv.3
output = process.argv.4

if !(fontfile and code and output) =>
  [fontfile,code,output] = [
    "../sample/王漢宗正海報.ttf",
    "的一是有在人不大中為以國會上了我年時來這他",
    "../output/subset.ttf"
  ]
  console.log "usage: lsc subset <fontfile> <codes/code.txt> <output-filename>"
  console.log " - use default sample config instead:"
  console.log "   fontfile: #fontfile"
  console.log "   code:     #code"
  console.log "   output:   #output"

if fs.exists-sync code => code = fs.read-file-sync code .toString!
hash = {}
for i from 0 til code.length => hash[code[i]] = true
code = [k for k of hash].join('')
console.log code
fs-extra.ensure-dir-sync path.dirname(output)
fm  = new fontmin!src fontfile
fm.dest "."
  .use gulp-rename output
  .use fontmin.glyph text: code
  .run (e, f) -> console.log "finished."

