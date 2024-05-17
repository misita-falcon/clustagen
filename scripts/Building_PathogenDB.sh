### Building PathogenDB

mkdir PathogenDB
PathogenDB = ~/Desktop/PathogenDB

# STEP 1
# Install a taxonomy. Usually, you will just use the NCBI taxonomy, which you can easily download using
# into pathogenDB

kraken2-build --download-taxonomy --db $PathogenDB

# STEP 2
# Prepare the genomes you’d like to add to your kraken database
# You will have to look up the taxonomy ID and add this to each fasta headers as I have done below. i.e.
# (>sequence”|kraken:taxid|390850)

# This just adds the taxids to the fasta headers, but does not affect sequencence
# Sequences with Tasid's are saved in genomesTax folder

PathogenDB = ~/Desktop/PathogenDB
bioawk -c fastx '{print ">"$name"|kraken:taxid|42789\n"$seq}' enterovirus\ D68.fasta > $genomesTax/enterovirusD68Tax.fa


# After adding all taxa IDs: Build database for all newly added {genomes}Tax.fa files

for file in *.fa; do
kraken2-build --add-to-library $file --db $PathogenDB;
done

# STEP 3
# Build database with thread

kraken2-build --thread 8 --build --db $PathogenDB

# Classification
# To classify a set of sequences, use the kraken2 command:
# We call the Kraken2 tool and specify the database and fasta-file with the sequences it should use. 
# The general command structure looks like this:
# for single fasta file

kraken2 --use-names --threads 4 --db ~/Desktop/PathogenDB/ --report all.report.txt all.fasta > all.kraken

#!/bin/bash

# for paired-end data
PathogenDB=/home2/cmmoranga/PathogenDB
cd /home2/cmmoranga/data_paired_reads

#cd ~/Desktop/Kraken/paired_reads/data_paired_reads
mkdir Kraken
mkdir Kraken_report

# Loop through to run all files concurrently
for i in `ls *.gz | sed -e 's/\_[12].fastq.gz//' | sort | uniq`; do
kraken2 --threads 4 \
--db PathogenDB/ \
--report ${i%.gz}.report \
--gzip-compressed \
--paired ${i}_1.fastq.gz ${i}_2.fastq.gz > ${i%.gz}.kraken;
done

# move files generated to desire folders
mv /home2/cmmoranga/data_paired_reads/*.kraken ./Kraken
mv /home2/cmmoranga/data_paired_reads/*.report ./Kraken_report

# Move to Kraken_report folder and merge all report
cd Kraken_report
cat *.report > all.report

# Select 2 and 3 save
cat all.report | cut -f 2,3 > all.kraken.krona

# Generate kornal html file
ktImportTaxonomy all.kraken.krona
firefox taxonomy.krona.html


#python ~/Desktop/Kraken/paired_reads/combine_kreports.py -r *.report -o combined.report
bracken -i all.report -o all.bracken -d athogenDB -l S -t 4




python ~/Desktop/Kraken/paired_reads/Kraken_report/kreport2krona.py --intermediate-ranks -r all.report -o MYSAMPLE.krona 

# Test 2
for i in $( cd ~/Desktop/Kraken/paired_reads ; ls -1 *_1.fastq.gz | sed -e 's/_1.fastq.gz//g' ); do
#echo ${i}_1.fastq.gz ${i}_2.fastq.gz; 
kraken2 --use-names  --threads 4 \
--db ~/Desktop/PathogenDB/ \
--report ${i%.gz}.report.txt \
--gzip-compressed \
--paired ${i}_1.fastq.gz ${i}_2.fastq.gz > ${i}.kraken;
done

#########
# Bracken
#########

# Combined with the Kraken classifier, Bracken will produces more accurate species- 
# and genus-level abundance estimates than Kraken2 alone
# -l S: denotes the level we want to look at. S stands for species but other levels are available
# -d $PathogenDB: specifies the path to the Kraken2 database that should be used

# Run bracken-build to generate the kmer distribution file Read length (-l) depends on the basepair of the sequences

PathogenDB = ~/Desktop/PathogenDB

#Kraken2Dir = /home/waccbip/anaconda3/envs/assembly/bin/kraken2

bracken-build -d ~/Desktop/PathogenDB -t 4 -k 35 -l 100

bracken -i all.report -o all.bracken -d ~/Desktop/PathogenDB/ -l S -t 4
# Run Bracken for Abundance Estimation
python ~/Desktop/Kraken/est_abundance.py -i ~/Desktop/Kraken/paired_reads/Kraken_report/all.report -k ~/Desktop/PathogenDB/database100mers.kmer_distrib -l P -t 4 -o ~/Desktop/Kraken/paired_reads/Kraken_report/P_all.bracken
############

###########
# KRONA
###########  

# Update taxonomy
ktUpdateTaxonomy.sh ~/krona/taxonomy

cat all.report | cut -f 2,3 > all.kraken.krona
ktImportTaxonomy all.kraken.krona
firefox taxonomy.krona.html

