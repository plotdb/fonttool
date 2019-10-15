require! <[fs fs-extra opentype.js fontmin progress gulp-rename colors path svgo]>

filename = process.argv.2
out-dir = process.argv.3 or '../output/svg/'
if !(filename and out-dir) =>
  console.log "usage: lsc path.ls <font-filename> <output-dir>"
  process.exit -1

svgo = new svgo {full: true, plugins: [ { minifyStyles: {} } ]}
progress-bar = (total = 10, text = "converting") ->
  bar = new progress(
    "   #text [#{':bar'.yellow}] #{':percent'.cyan} :etas",
    { total: total, width: 60, complete: '#' }
  )
  return bar

opentype.load filename, (e, font) ->
  glyphs = font.glyphs.glyphs
  list = [0 til font.glyphs.length]
    .map(-> glyphs[it])
    .filter(->it and it.unicode)
  bar = progress-bar list.length, "converting"
  fs-extra.ensure-dir-sync out-dir
  out = []
  _ = ->
    setTimeout (->
      item = list.splice(0,1).0
      if !item => return fs.write-file-sync(path.join(out-dir, 'pathmap.txt'), out.join(\\n))
      bar.tick!
      c = item.unicode
      p = item.getPath!toPathData!
      svg = """<?xml version="1.0"?><svg xmlns="http://www.w3.org/2000/svg"><path d="#p"/></svg>"""
      svgo.optimize(svg)
        .catch -> return {data: svg}
        .then (ret) -> 
          svg = ret.data
          d = (/path d="(.*)"/.exec(svg))
          d = d.1
          fs.write-file-sync path.join(out-dir, "#{item.unicode}"), d
          fs.write-file-sync path.join(out-dir, "#{item.unicode}.svg"), svg
          out.push "#c #d"
          _!
        .catch -> console.log it
    ), 0
  _!
