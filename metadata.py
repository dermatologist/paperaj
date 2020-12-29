import sys
from frontmatter import Frontmatter


post = Frontmatter.read_file(sys.argv[1])
with open(sys.argv[2], 'w') as abstract:
    abstract.write(post['attributes']['abstract'])

with open(sys.argv[3], 'w') as title:
    title.write(post['attributes']['title'])

with open(sys.argv[4], 'w') as author:
    author.write(post['attributes']['author'])


