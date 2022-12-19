# paperaj

Paperaj is a combination of bash and python scripts for converting MS word document to a latex document for academic journals. You can use any journal template for latex compilation. This can be used as a standalone script (needs pandoc and latex installed) or as a GitHub action. **When used as a GitHub action, there is no need to clone this repository.** Just clone [this template](https://github.com/dermatologist/paperaj-public-template) that uses this GitHub action.

[![paperaj](https://github.com/dermatologist/paperaj/blob/develop/paperaj.drawio.svg)](https://github.com/dermatologist/paperaj/blob/develop/paperaj.drawio.svg)


## Usage

* Use this [github template](https://github.com/dermatologist/paperaj-public-template)
* Use the docx in the template
* Add bib and tex files.
* set the names of docx, bib and latex entry in paperaj.env file (full path if you are using locally)
* run the script (if using locally)
```
    ./article.sh paperaj.env
```
* [This template](https://github.com/dermatologist/paperaj-public-template) generates LaTeX files on push to develop branch and compile to PDF on push to main branch!
### Arguments in .env file

* BIBLIO=references.bib
* DOCX=article.docx
* PDF=article.pdf
* LATEXFOLDER=./ # no trailing /
* LATEXENTRY=main.tex
* BIBCOMPILE=bibtex or biber
* TEXCOMPILE=defer or yes
* ACRONYMS=sample.csv
* GLOSSARY=sample.csv
* MINDMAP=create
* CITETAG= cite or citep
* PANDOCPATH=
### Figures

* Use TWO_COLUMN or LATEXROTATE in captions of figure
* FIGURE_ or TABLE_ for inline ref

### Referencing

\cite{AuthorYEAR} inline
#### Using Zotero

### Flatten

### arXiv


### Clean version for submission


### Mindmapping

#### [plant UML](https://github.com/plantuml/plantuml/releases/download/v1.2022.14/plantuml-1.2022.14.jar)

* '** first'
* '*** second'
* '**_' adds title

* Add the above to the Zotero notes for references

### Notebook to pdf
* jupyter-nbconvert --to pdf acnode.ipynb

### Extract highlights from PDF
[pdfannots](https://pypi.org/project/pdfannots/)