# Reconstructing near full-length 16S rDNA sequences from gene capture by hybridization

You can find here the bash script used in "Revealing microbial species diversity using sequence capture by hybridization" to reconstruct near full-length 16S rDNA sequences from sequencing data gained by gene capture.

This script takes as input paired end reads (fastq file). We considered that sequence adaptater were removed by the sequencing platform.

Tools necessary to run this script are listed below.
- For quality trimming: <a class="reference external" href="https://github.com/uwb-linux/prinseq" target="_blank" rel="noopener noreferrer">Prinseq-lite</a>
- To filter 16S reads: <a class="reference external" href="https://bioinfo.lifl.fr/RNA/sortmerna/" target="_blank" rel="noopener noreferrer">SortMeRNA</a> v2.1
- To reconstruct full-length SSU rRNA sequences: <a class="reference external" href="https://github.com/csmiller/EMIRGE" target="_blank" rel="noopener noreferrer">EMIRGE</a> v0.60
- Classify the full-length reconstructed SSU sequences: the Python script <a class="reference external" href="http://qiime.org/scripts/assign_taxonomy.html" target="_blank" rel="noopener noreferrer">assign_taxonomy.py</a> of QIIME v1.9.1 and the <a class="reference external" href="https://www.arb-silva.de/download/archive/qiime" target="_blank" rel="noopener noreferrer">SILVA119</a> QIIME compatible database.

 Please install these tools in your ```$PATH``` according to their author's recommendations.
## Preparing databases

SortMeRNA and EMIRGE were fed with the SILVA SSU 119 database which need to be indexed separately for each tool.

### Indexing SortMeRNA database

SortMeRNA provided rRNA databases in the 'sortmerna- 2.1/rRNA databases' folder.
To index the 16S rRNA database use the following line.

```bash
sortmerna-2.1-linux-64/indexdb_rna --ref \
./rRNA_databases/silva-bac-16s-id90.fasta,./index/silva-bac-16s-db:\
./rRNA_databases/silva-arc-16s-id95.fasta,./index/silva-arc-16s-db:\
./rRNA_databases/silva-euk-18s-id95.fasta,./index/silva-euk-18s-db
```

### Indexing EMIRGE database

EMIRGE provided a specific script to download and index the current version of the Silva SSU rRNA database (SILVA119 in this work).
Run the following command.

```bash
python emirge_makedb.py
```

## Running the bash script

Run the following command.

```bash
bash CaptOTU_16S_reconstruction.sh
```

