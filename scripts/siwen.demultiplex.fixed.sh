INPUT="Q10_All_eDNA.fastq"
TAGS="tags.txt"
PRIMER_F="GTGCCAGCMGCCGCGGTAA"
PRIMER_R="GGACTACHVGGGTWTCTAAT"
MIN_LENGTH=200
MIN_F=$(( ${#PRIMER_F} * 2 / 3 ))
MIN_R=$(( ${#PRIMER_R} * 2 / 3 ))


VSEARCH=$(which vsearch)
INPUT_REVCOMP=$(mktemp)
TMP_FASTQ="Output.fastq"
"${VSEARCH}" --quiet --fastx_revcomp "${INPUT}" --fastqout "${INPUT_REVCOMP}"

CUTADAPT=$(which cutadapt)

echo "$CUTADAPT"
while read TAG_NAME TAG_SEQ RTAG_SEQ; do
	echo "Processing ${TAG_NAME}..."
	LOG="${TAG_NAME}.log"

	OUTPUT="${TAG_NAME}.fastq"

	cat "${INPUT}" "${INPUT_REVCOMP}"|\
	"${CUTADAPT}" --discard-untrimmed -g "${TAG_SEQ}" -O 6 --error-rate 0.2 - 2> "${LOG}"|\
	"${CUTADAPT}" -g "${PRIMER_F}" -O "${MIN_F}" - 2>> "${LOG}"|\
	"${CUTADAPT}" --discard-untrimmed -a "${RTAG_SEQ}" -O 6 --error-rate 0.2 - 2>> "${LOG}"|\
	"${CUTADAPT}" -a "${PRIMER_R}" -O "${MIN_R}" --minimum-length ${MIN_LENGTH} -o "${OUTPUT}" - 2>> "${LOG}"

	COUNT=$(grep -c "^@" "${OUTPUT}" 2>/dev/null || echo 0)
	echo "--> ${COUNT} reads in ${OUTPUT}"
	grep "READS written" "${LOG}" || echo "No reads passed filters"
	echo "--------------------------------------"
done < "${TAGS}"

rm -f "${INPUT_REVCOMP}"
	

