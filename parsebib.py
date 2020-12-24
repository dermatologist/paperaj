import sys
with open(sys.argv[1]) as bib, open(sys.argv[2], 'w') as puml:
    puml.write("@startmindmap myMindMap\n")
    puml.write("* Mindmap\n")
    title = ""
    for line in bib:
        if "title" in line:
            title = line
        if "**" in line:
            puml.write(line)
        if "*_" in line:
            puml.write(line + " " + title)
    puml.write("@endmindmap")
