#!/usr/bin/python
import re
import sys
# Using for loop 
count = 0
latex_rotate = False
#print("\nUsing " + sys.argv[1]) 
to_write=[]  
with open(sys.argv[1]) as fp: 
    for line in fp: 
        count += 1
        if(line.startswith("Figure ")):
            caption = line.strip().split(":")
            caption_figure = caption[0].replace(" ", "_")
            if "LATEXROTATE" in caption[1]:
                latex_rotate = True    
            caption_text = caption[1].replace("LATEXROTATE", "").strip()
            #print(caption_figure, caption_text)
            line=""

        if(line.startswith("\\begin{figure}") and latex_rotate):
            line = line.replace("{figure}", "{sidewaysfigure}")
            #to_write.append(line)
            #print(line)

        if(line.startswith("\\end{figure}") and latex_rotate):
            line = line.replace("{figure}", "{sidewaysfigure}")
            #to_write.append(line)
            latex_rotate = False
            #print(line)

        # Line break
        if(line.startswith("\\textbackslash\\textbackslash{}")):
            line = line.replace("\\textbackslash\\textbackslash{}\n", "\\vskip 0.43in")
            #print(line)
        # Generic latex commands add \\\
        if(line.startswith("\\textbackslash\\textbackslash\\textbackslash")):
            line = line.replace("\\textbackslash\\textbackslash\\textbackslash ", "\\")
            #print(line)

        if(line.startswith("\caption{image}")):
            line = line.replace("image", caption_text)
            to_write.append(line)
            #print(line)
            to_write.append("")
            line = "\label{" + caption_figure + "} "
            to_write.append(line)
            #print(line)
            to_write.append("")
            line="\n"

        if(line.startswith("Table ")):
            caption = line.strip().split(":")
            caption_table = caption[0].replace(" ", "_")
            if(caption_table == "Table_"):
                caption_table = "Table_1"
            caption_table_text = caption[1].strip()
            #print(caption_table, caption_table_text)
            line=""
        if(line.startswith("\\begin{longtable}")):
            to_write.append(line)
            #print(line)
            to_write.append("")
            line = "\caption{" + caption_table_text + "} "
            to_write.append(line)
            #print(line)
            to_write.append("\n")
            line = "\label{" + caption_table + "} \\\\"
            to_write.append(line)
            #print(line)
            to_write.append("")
            line="\n"
        # New rule for split heading for long tables
        if(line.startswith("\midrule")):
            to_write.append(line)
            #print(line)
            to_write.append("")
            line = "\endfirsthead"
            to_write.append(line)
            #print(line)
            to_write.append("\n")
            line = "\caption* {Table \\ref{" + caption_table + "} Continued: " + caption_table_text + "} \\\\ \\toprule"
            to_write.append(line)
            #print(line)
            to_write.append("")
            line="\n"

        # if " Figure: " in line:
        #     line = line.replace(" Figure: ", " Figure: \\ref{" + caption_figure + "}")
        #     #print(line)
        fig_ref = re.search("Figure\\\_\d+", line)
        if fig_ref:
            line = re.sub("Figure\\\_\d+", " Figure \\\\ref{" + fig_ref.group(0).replace("\\", "") + "}", line)
            #print(line)
        table_ref = re.search("Table\\\_\d+", line)
        if table_ref:
            line = re.sub("Table\\\_\d+", " Table \\\\ref{" + table_ref.group(0).replace("\\", "") + "}", line)
            #print(line)
        appendix_ref = re.search("Appendix\\\_[A-E]+", line)
        if appendix_ref:
            line = re.sub("Appendix\\\_[A-E]+", " Appendix \\\\ref{" + appendix_ref.group(0).replace("\\", "")  + "}", line)
            #print(line)

        if " -\/-\/- " in line:
            line = line.replace(" -\/-\/- ", " --- ")
            #print(line)

        if " et al." in line:
            line = line.replace(" et al.", "")
            #print(line)
       
        if "\\{" in line:
            line = line.replace("\\{", "{")
            #print(line)

        if "\\}" in line:
            line = line.replace("\\}", "}")
            #print(line)

        to_write.append(line)
# Writing to file 
with open(sys.argv[2], "w") as fp: 
    fp.writelines(to_write) 