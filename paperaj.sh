#!/bin/bash
# Takes 2 command line arguments
# 1 is the file to be processed
# 2 is the output directory

DOCX=$1
LATEXFOLDER=$2
FILENAME=${DOCX%.*}
POSTFIX="${FILENAME: -10}"


# Exit if no arguments
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

# Remove temp files
rm /tmp/latex-files-*
[ ! -d "$LATEXFOLDER/paperaj-$POSTFIX" ] && mkdir "$LATEXFOLDER/paperaj-$POSTFIX"

# Extract media
"${PANDOCPATH}pandoc" --extract-media $LATEXFOLDER/ -i "$DOCX" -s --wrap=preserve -o /tmp/latex-files-temp-1.md

sed -e 's/!\[\](media/!\[image\](media/g' /tmp/latex-files-temp-1.md > /tmp/latex-files-temp-11.md
"${PANDOCPATH}pandoc" -i /tmp/latex-files-temp-11.md --wrap=auto --columns=140 -o /tmp/latex-files-temp-2.tex
echo "Conversion Complete"

cat /tmp/latex-files-temp-2.tex | sed -e 's/\\hypertarget{.*}{\%//g' > /tmp/latex-files-temp-5.tex
cat /tmp/latex-files-temp-5.tex | sed -e 's/\\label{.*}//g' > /tmp/latex-files-temp-6a.tex

# add \cite{}
cat /tmp/latex-files-temp-6a.tex | sed -e 's/\\textbackslash.*cite\\{/\\cite{/g' > /tmp/latex-files-temp-6b.tex
cat /tmp/latex-files-temp-6b.tex | sed -e 's/\\textbackslash.*citet\\{/\\citet{/g' > /tmp/latex-files-temp-6c.tex
# add \tab -> \qquad
cat /tmp/latex-files-temp-6c.tex | sed -e 's/\\textbackslash tab/\\qquad/g' > /tmp/latex-files-temp-6d.tex
cat /tmp/latex-files-temp-6d.tex | sed -e 's/\\textbackslash{}tab/\\qquad/g' > /tmp/latex-files-temp-7.tex


# Remove line breaks added on 3/21/2021
awk ' /^\\/ { printf("%s \n", $0); } /^$/ { print "\n"; }  /^[^\\].*/ { printf("%s ", $0); } END { print ""; } ' /tmp/latex-files-temp-7.tex > /tmp/latex-files-temp-7a.tex
python images.py /tmp/latex-files-temp-7a.tex /tmp/latex-files-temp-8.tex

# Split file into section chapters. Last one will be references
csplit -k -f /tmp/latex-files- /tmp/latex-files-temp-8.tex '/\\section{\\texorpdfstring{\\emph{/' '{15}'
for i in {0..20} # upto 20 sections
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
        cp /tmp/latex-files-$ia "$LATEXFOLDER/paperaj-$POSTFIX/chapter-$i.tex"
    fi
done