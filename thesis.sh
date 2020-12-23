#!/bin/bash
rm /tmp/latex-files-*
pandoc -i $1 --bibliography=../latex/thesis.bib --wrap=preserve --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-1.md
addimagetag.sh /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
pandoc -i /tmp/latex-files-temp-11.md --bibliography=../latex/thesis.bib --wrap=auto --columns=140 --csl=word2latex-pandoc.csl -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"
cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex
# cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.*cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
# cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.*citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.cite\\{/\\citep{/g' > /tmp/latex-files-temp-6b.tex
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.citet\\{/\\citet{/g' > /tmp/latex-files-temp-6.tex
python images.py /tmp/latex-files-temp-6.tex /tmp/latex-files-temp-7.tex
csplit -f /tmp/latex-files- /tmp/latex-files-temp-7.tex '/\\section{\\texorpdfstring{\\emph{/' {12}
echo "Processing complete"
cat /tmp/latex-files-01 | sed -e '1,2d' > /tmp/latex-files-01a
cp /tmp/latex-files-01a ~/Documents/gitcola/thesis-overleaf/chapters/introduction.tex
cat /tmp/latex-files-02 | sed -e '1,2d' > /tmp/latex-files-02a
cp /tmp/latex-files-02a ~/Documents/gitcola/thesis-overleaf/chapters/review_of_literature.tex
cat /tmp/latex-files-03 | sed -e '1,2d' > /tmp/latex-files-03a
cp /tmp/latex-files-03a ~/Documents/gitcola/thesis-overleaf/chapters/aims_objectives.tex
cat /tmp/latex-files-04 | sed -e '1,2d' > /tmp/latex-files-04a
cp /tmp/latex-files-04a ~/Documents/gitcola/thesis-overleaf/chapters/materials_methods.tex
cat /tmp/latex-files-05 | sed -e '1,2d' > /tmp/latex-files-05a
cp /tmp/latex-files-05a ~/Documents/gitcola/thesis-overleaf/chapters/results.tex
cat /tmp/latex-files-06 | sed -e '1,2d' > /tmp/latex-files-06a
cp /tmp/latex-files-06a ~/Documents/gitcola/thesis-overleaf/chapters/discussion.tex
cat /tmp/latex-files-07 | sed -e '1,2d' > /tmp/latex-files-07a
cp /tmp/latex-files-07a ~/Documents/gitcola/thesis-overleaf/chapters/conclusion.tex
echo "\label{Appendix_A}" > /tmp/latex-files-08a
cat /tmp/latex-files-08 | sed -e '1,2d' >> /tmp/latex-files-08a
cp /tmp/latex-files-08a ~/Documents/gitcola/thesis-overleaf/chapters/appendix1.tex
echo "\label{Appendix_B}" > /tmp/latex-files-09a
cat /tmp/latex-files-09 | sed -e '1,2d' >> /tmp/latex-files-09a
cp /tmp/latex-files-09a ~/Documents/gitcola/thesis-overleaf/chapters/appendix2.tex
echo "\label{Appendix_C}" > /tmp/latex-files-10a
cat /tmp/latex-files-10 | sed -e '1,2d' >> /tmp/latex-files-10a
cp /tmp/latex-files-10a ~/Documents/gitcola/thesis-overleaf/chapters/appendix3.tex
echo "\label{Appendix_D}" > /tmp/latex-files-11a
cat /tmp/latex-files-11 | sed -e '1,2d' >> /tmp/latex-files-11a
cp /tmp/latex-files-11a ~/Documents/gitcola/thesis-overleaf/chapters/appendix4.tex
echo "\label{Appendix_E}" > /tmp/latex-files-12a
cat /tmp/latex-files-12 | sed -e '1,2d' >> /tmp/latex-files-12a
cp /tmp/latex-files-12a ~/Documents/gitcola/thesis-overleaf/chapters/appendix5.tex
# Last file with references is discarded
cat ../latex/thesis-old-v3.bib > ~/Documents/gitcola/thesis-overleaf/references.bib
cat ../latex/thesis-new-v4.bib >> ~/Documents/gitcola/thesis-overleaf/references.bib
cat ../latex/thesis-discussion.bib >> ~/Documents/gitcola/thesis-overleaf/references.bib

cp ../misc/Tables/acronyms.csv ~/Documents/gitcola/thesis-overleaf/
cp ../misc/Tables/glossary.csv ~/Documents/gitcola/thesis-overleaf/
echo "Copy complete"
