##lines=$(wc -l < Q10_All_eDNA.fastq_5GB.fastq)
#safe_lines=$((lines / 4 * 4))
#head -n $safe_lines Q10_All_eDNA.fastq_5GB.fastq > subsample.fastq

#DAY2
#Basecalling using Dorado
#dorado basecaller hac pod5/ > calls.bam

#convert to fastq
#samtools fastq calls.bam > All_eDNA.fastq

#Quality check before filtering
#NanoPlot --fastq All_eDNA.fastq -o nanoplot_All_eDNA.fastq_output

#Filtering
#seqtk seq -q10 All_eDNA.fastq > Q10_All_eDNA.fastq

#Quality Check
#NanoPlot --fastq Q10_All_eDNA.fastq -o nanoplot_Q10_output

#Demultiplexing
#Ensure you have the Mids.txt file (PCR tags)
#Define inputs and constants
INPUT="subsample.fastq"
TAGS="mids.txt"
#Define primers explicitly

PRIMER_F="GTGCCAGCMGCCGCGGTAA"
PRIMER_R="GGACTACHVGGGTWTCTAAT"

#Minimum read length
MIN_LENGTH=200

#Compute minimum primer overlap dynamically
#Nanopore has higher error rate therefore full-length exact primer matches are unrealistic
MIN_F=$(( ${#PRIMER_F} * 2 / 3 ))
MIN_R=$(( ${#PRIMER_R} * 2 / 3 ))

#Pre-build the cutadapt command
CUTADAPT="$(which cutadapt)"
#--discard-untrimmed --minimum-length ${MIN_LENGTH}"

VSEARCH=$(which vsearch)

INPUT_REVCOMP=$(mktemp)


#Reverse-complement ALL reads FIRST
#Nanopore reads can be forward or reverse
#This prevents losing ~50% of valid reads

"${VSEARCH}" --quiet \
  --fastx_revcomp "${INPUT}" \
  --fastqout "${INPUT_REVCOMP}"

#DEMULTIPLEXING
#one pooled Nanopore FASTQ and splits it into one FASTQ per sample
#Ensures
#Only reads from Tag1....TagN
#No tags
#No primers
#Correct orientation
#Clean amplicons

while read TAG_NAME TAG_SEQ RTAG_SEQ; do

  echo "Processing ${TAG_NAME}..."

  LOG="bac_hac_end_${TAG_NAME}.log"
  OUTPUT="bac_hac_end_${TAG_NAME}.fastq"

  cat "$INPUT" "$INPUT_REVCOMP" | \
  "$CUTADAPT" \
    --discard-untrimmed \
    -g "$TAG_SEQ" \
    -O 6 \
    --error-rate 0.2 \
    - 2> "$LOG" | \
  "$CUTADAPT" \
    -g "$PRIMER_F" \
    -O "$MIN_F" \
    - 2>> "$LOG" | \
  "$CUTADAPT" \
    -a "$RTAG_SEQ" \
    -O 6 \
    --error-rate 0.2 \
    - 2>> "$LOG" | \
  "$CUTADAPT" \
    -a "$PRIMER_R" \
    -O "$MIN_R" \
    --minimum-length "$MIN_LENGTH" \
    -o "$OUTPUT" \
    - 2>> "$LOG"

  COUNT=$(grep -c "^@" "$OUTPUT" 2>/dev/null || echo 0)
  echo "--> ${COUNT} reads in ${OUTPUT}"

  grep "Reads written" "$LOG" || echo "No reads passed filters"
  echo "--------------------------------------"

done < "$TAGS"


rm "${INPUT_REVCOMP}"

