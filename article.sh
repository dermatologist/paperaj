#!/bin/bash

# Export the vars in .env into your shell:
DOCX=$(grep DOCX $1 | xargs)
BIBLIO=$(grep BIBLIO $1 | xargs)
CHAPTER=$(grep CHAPTER $1 | xargs)
LATEXFOLDER=$(grep LATEXFOLDER $1 | xargs)
LATEXENTRY=$(grep LATEXENTRY $1 | xargs)
PDF=$(grep PDF $1 | xargs)
BIBCOMPILE=$(grep BIBCOMPILE $1 | xargs)
DOCTYPE=$(grep DOCTYPE $1 | xargs)
ACRONYMS=$(grep ACRONYMS $1 | xargs)
GLOSSARY=$(grep GLOSSARY $1 | xargs)
TEXCOMPILE=$(grep TEXCOMPILE $1 | xargs)
MINDMAP=$(grep MINDMAP $1 | xargs)
CITETAG=$(grep CITETAG $1 | xargs)


# Remove XX= prefix - https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
DOCX=${DOCX#"DOCX="}
BIBLIO=${BIBLIO#"BIBLIO="}
CHAPTER=${CHAPTER#"CHAPTER="}
LATEXFOLDER=${LATEXFOLDER#"LATEXFOLDER="}
LATEXENTRY=${LATEXENTRY#"LATEXENTRY="}
PDF=${PDF#"PDF="}
BIBCOMPILE=${BIBCOMPILE#"BIBCOMPILE="}
DOCTYPE=${DOCTYPE#"DOCTYPE="}
ACRONYMS=${ACRONYMS#"ACRONYMS="}
GLOSSARY=${GLOSSARY#"GLOSSARY="}
TEXCOMPILE=${TEXCOMPILE#"TEXCOMPILE="}
MINDMAP=${MINDMAP#"MINDMAP="}
CITETAG=${CITETAG#"CITETAG="}

rm /tmp/latex-files-*

pandoc -i "$DOCX" --bibliography="$BIBLIO" --wrap=preserve --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-1.md
./addimagetag.sh /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
pandoc -i /tmp/latex-files-temp-11.md --bibliography="$BIBLIO" --wrap=auto --columns=140 --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"
cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex
if [ "$CITETAG" != "citep" ]
then
    cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.cite\\{/\\cite{/g' > /tmp/latex-files-temp-6b.tex
else
    cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
fi
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
python images.py /tmp/latex-files-temp-6.tex /tmp/latex-files-temp-7.tex

if [ "$DOCTYPE" != "thesis" ]
then
    csplit -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' # Remove references
    cat /tmp/latex-files-00 | sed -e '1,2d' > /tmp/latex-files-00a
    cp /tmp/latex-files-00a "$CHAPTER"

else
    csplit -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' {12}
    echo "Processing complete"
    cat /tmp/latex-files-01 | sed -e '1,2d' > /tmp/latex-files-01a
    cp /tmp/latex-files-01a "$LATEXFOLDER/chapters/introduction.tex"
    cat /tmp/latex-files-02 | sed -e '1,2d' > /tmp/latex-files-02a
    cp /tmp/latex-files-02a "$LATEXFOLDER/chapters/review_of_literature.tex"
    cat /tmp/latex-files-03 | sed -e '1,2d' > /tmp/latex-files-03a
    cp /tmp/latex-files-03a "$LATEXFOLDER/chapters/aims_objectives.tex"
    cat /tmp/latex-files-04 | sed -e '1,2d' > /tmp/latex-files-04a
    cp /tmp/latex-files-04a "$LATEXFOLDER/chapters/materials_methods.tex"
    cat /tmp/latex-files-05 | sed -e '1,2d' > /tmp/latex-files-05a
    cp /tmp/latex-files-05a "$LATEXFOLDER/chapters/results.tex"
    cat /tmp/latex-files-06 | sed -e '1,2d' > /tmp/latex-files-06a
    cp /tmp/latex-files-06a "$LATEXFOLDER/chapters/discussion.tex"
    cat /tmp/latex-files-07 | sed -e '1,2d' > /tmp/latex-files-07a
    cp /tmp/latex-files-07a "$LATEXFOLDER/chapters/conclusion.tex"
    echo "\label{Appendix_A}" > /tmp/latex-files-08a
    cat /tmp/latex-files-08 | sed -e '1,2d' >> /tmp/latex-files-08a
    cp /tmp/latex-files-08a "$LATEXFOLDER/chapters/appendix1.tex"
    echo "\label{Appendix_B}" > /tmp/latex-files-09a
    cat /tmp/latex-files-09 | sed -e '1,2d' >> /tmp/latex-files-09a
    cp /tmp/latex-files-09a "$LATEXFOLDER/chapters/appendix2.tex"
    echo "\label{Appendix_C}" > /tmp/latex-files-10a
    cat /tmp/latex-files-10 | sed -e '1,2d' >> /tmp/latex-files-10a
    cp /tmp/latex-files-10a "$LATEXFOLDER/chapters/appendix3.tex"
    echo "\label{Appendix_D}" > /tmp/latex-files-11a
    cat /tmp/latex-files-11 | sed -e '1,2d' >> /tmp/latex-files-11a
    cp /tmp/latex-files-11a "$LATEXFOLDER/chapters/appendix4.tex"
    echo "\label{Appendix_E}" > /tmp/latex-files-12a
    cat /tmp/latex-files-12 | sed -e '1,2d' >> /tmp/latex-files-12a
    cp /tmp/latex-files-12a "$LATEXFOLDER/chapters/appendix5.tex"
    # Last file with references is discarded
    cp "$ACRONYMS" "$LATEXFOLDER"
    cp "$GLOSSARY" "$LATEXFOLDER"
    echo "Copy complete"
fi

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

echo "Processing complete"

if [ "$MINDMAP" == "create" ]
then
    echo "Creating mindmap"
    python parsebib.py "$BIBLIO" "$BIBLIO.puml"
    java -jar plantuml.jar "$BIBLIO.puml"
fi