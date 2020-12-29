import sys
import markdown

with open(sys.argv[1], 'r') as file:
    data = file.read()

md = markdown.Markdown(extensions=['full_yaml_metadata'])
md.convert(data)

with open(sys.argv[2], 'w') as abstract:
    abstract.write(md.Meta['abstract'])

with open(sys.argv[3], 'w') as title:
    title.write(md.Meta['title'])

with open(sys.argv[4], 'w') as author:
    author.write(md.Meta['author'])


