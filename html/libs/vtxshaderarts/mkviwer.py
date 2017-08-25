import sys
import os

if len(sys.argv) < 2:
    sys.stderr.write("usage: {} input.shader > output.html\n".format(sys.argv[0]))
    sys.exit()

htmlbase = """<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<title>{}</title>
<link rel="stylesheet" href="libs/common/codeviewer.css">
<script src="libs/common/codeviewer.js"></script>
<link rel="stylesheet" href="libs/vtxshaderarts/vtxartsviewer.css">
<script>
var kEffectDefinition = {{
    drawMode: 'POINTS',
    vertexCount: 5000,
    background: {{r:0.0, g:0.0, b:0.0}},
    description: {{
        title: "",
        text: ""
    }}
}};
</script>
<script src="libs/vtxshaderarts/vtxartsviewer.js"></script>
<script type="text/text" id="shadersrc">
{}
</script>
</head><body></body></html>
"""

infile = sys.argv[1]
f = open(infile)
shadersrc = f.read()
f.close()
shadername = os.path.basename(infile)
html = htmlbase.format(shadername, shadersrc)
print(html)
