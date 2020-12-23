#!/bin/bash
cp $1 _main.tex
rm main.*
rm *.pdf
mv _main.tex main.tex
latex --interaction=batchmode main
biber main
latex --interaction=batchmode main
latex --interaction=batchmode main
pdflatex --interaction=batchmode main
