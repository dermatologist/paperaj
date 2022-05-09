#!/bin/bash

# activate venv
# source .venv/bin/activate

# Export the vars in .env into your shell:
DOCX=$(grep DOCX $1 | xargs)
BIBLIO=$(grep BIBLIO $1 | xargs)
LATEXFOLDER=$(grep LATEXFOLDER $1 | xargs)
LATEXENTRY=$(grep LATEXENTRY $1 | xargs)
PDF=$(grep PDF $1 | xargs)
BIBCOMPILE=$(grep BIBCOMPILE $1 | xargs)
ACRONYMS=$(grep ACRONYMS $1 | xargs)
GLOSSARY=$(grep GLOSSARY $1 | xargs)
TEXCOMPILE=$(grep TEXCOMPILE $1 | xargs)
MINDMAP=$(grep MINDMAP $1 | xargs)
CITETAG=$(grep CITETAG $1 | xargs)
PANDOCPATH=$(grep PANDOCPATH $1 | xargs)



# Remove XX= prefix - https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
DOCX=${DOCX#"DOCX="}
BIBLIO=${BIBLIO#"BIBLIO="}
LATEXFOLDER=${LATEXFOLDER#"LATEXFOLDER="}
LATEXENTRY=${LATEXENTRY#"LATEXENTRY="}
PDF=${PDF#"PDF="}
BIBCOMPILE=${BIBCOMPILE#"BIBCOMPILE="}
ACRONYMS=${ACRONYMS#"ACRONYMS="}
GLOSSARY=${GLOSSARY#"GLOSSARY="}
TEXCOMPILE=${TEXCOMPILE#"TEXCOMPILE="}
MINDMAP=${MINDMAP#"MINDMAP="}
CITETAG=${CITETAG#"CITETAG="}
PANDOCPATH=${PANDOCPATH#"PANDOCPATH="}

rm /tmp/latex-files-*
# -s adds abstract
"${PANDOCPATH}pandoc" -i "$DOCX" -s --bibliography="$BIBLIO" --wrap=preserve --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-1.md
# abstract
# cat /tmp/latex-files-temp-1.md | sed -n '/abstract:/,/author/p' | sed 's/abstract:/\\begin\{abstract\}/' | sed "s/author:.*/\\\end\{abstract\}/" | sed 's/\%/\\\%/g' > "$ABSTRACT"
mkdir "$LATEXFOLDER/paperaj"
python metadata.py /tmp/latex-files-temp-1.md /tmp/latex-files-temp-1m.md "$LATEXFOLDER/paperaj/title.tex" "$LATEXFOLDER/paperaj/author.tex"
"${PANDOCPATH}pandoc" -i /tmp/latex-files-temp-1m.md -o "$LATEXFOLDER/paperaj/abstract.tex"

./addimagetag.sh /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
"${PANDOCPATH}pandoc" -i /tmp/latex-files-temp-11.md --bibliography="$BIBLIO" --wrap=auto --columns=140 --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"
cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex
if [ "$CITETAG" != "citep" ]
then
    cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.*cite\\{/\\cite{/g' > /tmp/latex-files-temp-6b.tex
else
    cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.*cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
fi
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.*citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
# Remove line breaks added on 3/21/2021
awk ' /^\\/ { printf("%s \n", $0); } /^$/ { print "\n"; }  /^[^\\].*/ { printf("%s ", $0); } END { print ""; } ' /tmp/latex-files-temp-6.tex > /tmp/latex-files-temp-6c.tex
python images.py /tmp/latex-files-temp-6c.tex /tmp/latex-files-temp-7.tex

# Split file into section chapters. Last one will be references
csplit -k -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' '{15}'
for i in {0..15} # upto 15 sections
do
    size=${#i}
    if [ $size == 1 ]
    then
        i="0${i}"  # the format is latex-files-0x. 0 added for i has onle one digit
    fi
    echo "Handling section: $i"
    if test -f "/tmp/latex-files-$i"; then
        # second part removes the session breat ie H1 header in italics
        cat /tmp/latex-files-$i | sed -e '1,2d' | sed -e 's/\\section{\\texorpdfstring{\\emph{.*//g' > /tmp/latex-files-$ia
        cp /tmp/latex-files-$ia "$LATEXFOLDER/paperaj/chapter-$i.tex"
    fi
done
cp "$BIBLIO" "$LATEXFOLDER"
cp "$ACRONYMS" "$LATEXFOLDER"
cp "$GLOSSARY" "$LATEXFOLDER"

if [ "$TEXCOMPILE" != "defer" ]
then
    # Copy latex folder locally
    cp -r "$LATEXFOLDER" ./latex

    if [ "$BIBCOMPILE" == "biber" ]
    then
        echo "Using Biber"
        cp biber.sh ./latex/compile.sh
    else
        echo "Using Bibtex"
        cp bibtex.sh ./latex/compile.sh
    fi

    cd ./latex
    ./compile.sh "$LATEXENTRY"
    cp main.pdf "$PDF"
    cd ..
    rm -rf ./latex
fi

echo "Creating cleaned version"
rm -rf "$LATEXFOLDER/clean"
arxiv_latex_cleaner "$LATEXFOLDER" --verbose
mv "${LATEXFOLDER}_arXiv" "$LATEXFOLDER/clean"
cp -n -r "$LATEXFOLDER/paperaj/" "$LATEXFOLDER/clean/"
cp -n -r "$LATEXFOLDER/media/" "$LATEXFOLDER/clean/"


echo "Creating ArXiv version"
rm -rf "$LATEXFOLDER/arxiv"
cp -r arxiv "$LATEXFOLDER/arxiv"
cp -r "$LATEXFOLDER/clean/paperaj" "$LATEXFOLDER/arxiv/paperaj"
cp -r "$LATEXFOLDER/clean/media" "$LATEXFOLDER/arxiv/media"
cp "$BIBLIO" "$LATEXFOLDER/arxiv/references.bib"
cp "$LATEXFOLDER/authors.tex" "$LATEXFOLDER/arxiv/authors.tex"
cp "$LATEXFOLDER/inclusions.tex" "$LATEXFOLDER/arxiv/inclusions.tex"

"""
Creates flat version for Springer
Requires flatten.bak in $LATEXFOLDER
Requires sn-jnl.cls and the sn-vancouver.cls or similar.
"""
echo "Creating flat version"
if [  -d "$LATEXFOLDER/flatten" ]
then
    cp -a "$LATEXFOLDER/clean/paperaj/." "$LATEXFOLDER/flatten"
    cp -a "$LATEXFOLDER/clean/media/." "$LATEXFOLDER/flatten"
    cp -a "$LATEXFOLDER/clean/inclusions.tex" "$LATEXFOLDER/flatten/inclusions.tex"
    cp "$BIBLIO" "$LATEXFOLDER/flatten/references.bib"
    #cp "$LATEXFOLDER/$LATEXENTRY" "$LATEXFOLDER/flatten/main.tex"
    find "$LATEXFOLDER/flatten" -type f -name "*.tex" -exec sed -i 's/media\///g' {} +
    find "$LATEXFOLDER/flatten" -type f -name "*.tex" -exec sed -i 's/paperaj\///g' {} +
    #find "$LATEXFOLDER/flatten" -type f -name "*.tex" -exec sed -i 's/citep/cite/g' {} +
    CURRENT_DIR=`pwd`
    cd "$LATEXFOLDER/flatten"
    python "$CURRENT_DIR/flatten.py" inclusions.tex inclusions-expanded.tex
    rm inclusions.tex
    mv inclusions-expanded.tex inclusions.tex
    python "$CURRENT_DIR/flatten.py" "$LATEXFOLDER/flatten.bak" main.bak
    rm *.tex
    mv main.bak main.tex
    cd $CURRENT_DIR
fi

echo "Compiling arxiv"
if [ "$TEXCOMPILE" != "defer" ]
then
    # Copy latex folder locally
    cp -r "$LATEXFOLDER/arxiv" ./latex

    if [ "$BIBCOMPILE" == "biber" ]
    then
        echo "Using Biber"
        cp biber.sh ./latex/compile.sh
    else
        echo "Using Bibtex"
        cp bibtex.sh ./latex/compile.sh
    fi

    cd ./latex
    ./compile.sh main.tex
    cp main.pdf "${PDF}.arxiv.pdf"
    cp main.bbl "$LATEXFOLDER/arxiv/main.bbl"
    cd ..
    rm -rf ./latex
fi


echo "Processing complete"

if [ "$MINDMAP" == "create" ]
then
    echo "Creating mindmap"
    python parsebib.py "$BIBLIO" "$BIBLIO.puml"
    java -jar plantuml.jar "$BIBLIO.puml"
fi