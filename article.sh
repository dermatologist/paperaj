#!/bin/bash

# Export the vars in .env into your shell:
export $(egrep -v '^#' $1 | xargs)

rm /tmp/latex-files-*
pandoc -i $DOCX --bibliography=$BIBLIO --wrap=preserve --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-1.md
addimagetag.sh /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
pandoc -i /tmp/latex-files-temp-11.md --bibliography=$BIBLIO --wrap=auto --columns=140 --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"
cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex
cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
python images.py /tmp/latex-files-temp-6.tex /tmp/latex-files-temp-7.tex
csplit -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' # Remove references
cat /tmp/latex-files-00 | sed -e '1,2d' > /tmp/latex-files-00a
cp /tmp/latex-files-00a $CHAPTER

# Copy latex folder locally
cp -r $LATEXFOLDER ./latex
cp compile.sh ./latex
cd latex
./compile.sh $LATEXENTRY $PDF
cd ..
rm -rf latex

echo "Processing complete"
