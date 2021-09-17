#!/bin/sh
#
#
#  This script takes in input separated fastq files (i.e. R1 and R2 files) 
#  from paired-end sequencing of products from gene capture by hybridization.
#  The complete script enables to extract 16S reads, reconstruct near 
#  full-length 16S rDNA sequences and perform taxonomic classification.
#
# contact: sophie.marre@uca.fr


# Raw sequencing data must be stored in a folder named with the sample name
 
# Complete before launching the bash script
sample_name=       # name of the sample
path=              # path to the folder containing the sample folder
THREADS= 	   # number of threads to use with SortMeRNA and EMIRGE
MAX_MEMORY=        # maximum memory to use with rdp (in Mo)


mkdir ./$sample_name/{1Trimming,2SortMeRNA,3EMIRGE,4Taxonomy}


### Trimming and quality control

prinseq-lite.pl \
    -fastq $path/$sample_name/${sample_name}_reads_R1.fastq \
    -fastq2 $path/$sample_name/${sample_name}_reads_R2.fastq \
    -out_format 3 \
    -out_good ${sample_name}_good_seq \
    -out_bad ${sample_name}_bad_seq \
    -log ./prinseq/.log \
    -no_qual_header \
    -min_qual_mean 25 \
    -ns_max_p 1 \
    -trim_qual_right 20 \
    -trim_qual_left 20 \
    -trim_qual_type mean \
    -trim_qual_rule lt \
    -trim_qual_window 3 \
    -trim_qual_step 1 \
    -min_len 60 \
    -verbose 

# Filtration of 16S rDNA reads

bash ./sortmerna-2.1-linux-64/scripts/merge-paired-reads.sh $path/$sample_name/1Trimming/${sample_name}_good_seq_1.fastq $path/$sample_name/1Trimming/${sample_name}_good_seq_2.fastq $path/$sample_name/1Trimming/${sample_name}_merged-trimmed-reads.fastq

sortmerna --ref ./sortmerna-2.1-linux-64/rRNA_databases/silva-bac-16s-id90.fasta,./sortmerna-2.1-linux-64/index/silva-bac-16s-db:./sortmerna-2.1-linux-64/rRNA_databases/silva-arc-16s-id95.fasta,./sortmerna-2.1-linux-64/index/silva-arc-16s-db --reads $path/$sample_name/1Trimming/${sample_name}_merged-trimmed-reads.fastq --fastx --aligned $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S --other $path/$sample_name/2SortMeRNA/${sample_name}_reads_other_than_16S18S --paired_in -a $THREADS --blast 1 -v --log

bash ./sortmerna-2.1-linux-64/scripts/unmerge-paired-reads.sh $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S.fastq $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S_R1.fastq $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S_R2.fastq


# EMIRGE reconstruction

./EMIRGE-0.61.1/emirge.py -1 $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S_R1.fastq -f ./EMIRGE-0.61.1/SILVA_119_SSURef_Nr99_tax_silva_trunc.ge1200bp.le2000bp.0.97.fixed.fasta -b /usr/local/bioinfo/EMIRGE-0.61.1/SILVA_119_SSURef_Nr99_tax_silva_trunc.ge1200bp.le2000bp.0.97.fixed -l 300 -2 $path/$sample_name/2SortMeRNA/${sample_name}_reads_16S_R2.fastq -i 500 -s 100 -a $THREADS --phred33 $path/$sample_name/3EMIRGE/

./EMIRGE-0.61.1/emirge_rename_fasta.py $path/$sample_name/3EMIRGE/iter.40 > $path/$sample_name/3EMIRGE/iter.40/${sample_name}_16S_reconstructed.fasta

# Taxonomic classification

assign_taxonomy.py -i $path/$sample_name/3EMIRGE/iter.40/${sample_name}_16S_reconstructed.fasta -m rdp -r ./SILVA_119_QIIME_release/rep_set/rep_set_16S_only/97/97_otus_16S.fasta -c 0.5 -o $path/$sample_name/4Taxonomy/${sample_name}_16S_reconstructed_taxonomy -v -t ./SILVA_119_QIIME_release/taxonomy/16S_only/97/consensus_taxonomy_7_levels.txt --rdp_max_memory $MAX_MEMORY






