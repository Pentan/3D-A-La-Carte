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
<script>
var kCodeDescription = {{
    title: "",
    text: ""
}};
</script>
<script src="libs/glslsandbox/sandboxviewer.js"></script>
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
