mkdir -p fastq
while read SRR; do
  echo "=== converting $SRR ==="
./sratoolkit.3.2.1-mac-x86_64/bin/fasterq-dump \
        "sra/$SRR/$SRR.sra" --threads 4 --outdir fastq

  # compress whatever was created: SRR.fastq or SRR_1.fastq (and _2 if paired)
  gzip fastq/${SRR}.fastq 2>/dev/null
  gzip fastq/${SRR}_*.fastq 2>/dev/null

  # quick sanity check on the first file found
  f=$(ls fastq/${SRR}*.fastq.gz 2>/dev/null | head -n 1)
  if [[ -n $f && -s $f ]]; then
    n=$(gunzip -c "$f" | wc -l)
    if (( n % 4 == 0 )); then
      echo "✓ $SRR looks good (lines = $n)"
    else
      echo "⚠ $SRR lines not multiple of 4 (lines = $n)"
    fi
  else
    echo "✗ $SRR file empty!"
  fi
  echo "=== $SRR done ==="
done < srr_ids.txt
