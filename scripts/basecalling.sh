#Basecalling using Dorado
dorado basecaller hac pod5 --device cpu --emit-fastq > All.fastq

#Quality check before filtering
NanoPlot --fastq All.fastq -o nanoplot_AllDNA.fastq_output

#Filtering
seqtk seq -q10 All.fastq > Q10_All.fastq

#Quality Check
NanoPlot --fastq Q10_All.fastq -o nanoplot_Q10_output
