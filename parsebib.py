with open('samples/ai-derm-bibtex.bib') as bib, open('samples/ai-derm-bibtex.puml', 'w') as puml:
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
