#!/bin/bash

# Export the vars in .env into your shell:
DOCX=$(grep DOCX $1 | xargs)
BIBLIO=$(grep BIBLIO $1 | xargs)
CHAPTER=$(grep CHAPTER $1 | xargs)
LATEXFOLDER=$(grep LATEXFOLDER $1 | xargs)
LATEXENTRY=$(grep LATEXENTRY $1 | xargs)
PDF=$(grep PDF $1 | xargs)
BIBCOMPILE=$(grep BIBCOMPILE $1 | xargs)

# Remove XX= prefix - https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
DOCX=${DOCX#"DOCX="}
BIBLIO=${BIBLIO#"BIBLIO="}
CHAPTER=${CHAPTER#"CHAPTER="}
LATEXFOLDER=${LATEXFOLDER#"LATEXFOLDER="}
LATEXENTRY=${LATEXENTRY#"LATEXENTRY="}
PDF=${PDF#"PDF="}
BIBCOMPILE=${BIBCOMPILE#"BIBCOMPILE="}

rm /tmp/latex-files-*

pandoc -i "$DOCX" --bibliography="$BIBLIO" --wrap=preserve --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-1.md
./addimagetag.sh /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
pandoc -i /tmp/latex-files-temp-11.md --bibliography="$BIBLIO" --wrap=auto --columns=140 --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"
cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex
cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
python images.py /tmp/latex-files-temp-6.tex /tmp/latex-files-temp-7.tex
csplit -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' # Remove references
cat /tmp/latex-files-00 | sed -e '1,2d' > /tmp/latex-files-00a
cp /tmp/latex-files-00a "$CHAPTER"

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

echo "Processing complete"
