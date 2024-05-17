#! /usr/bin/env bash

##create a kraken environment
#mamba create -n krakenx kraken2

#Activate environment
mamba activate krakenx

# for paired-end data
PathogenDB=/Users/collinsmisita/eDocuments/099_OceansM/cgenomics/PathogenDB
cd /Users/collinsmisita/eDocuments/099_OceansM/cgenomics/data_paired_reads

#cd ~/Desktop/Kraken/paired_reads/data_paired_reads
mkdir Kraken
mkdir Kraken_report

# Loop through to run all files concurrently
for i in `ls *.gz | sed -e 's/\_[12].fastq.gz//' | sort | uniq`; do
kraken2 --threads 4 \
--db $PathogenDB/ \
--report ${i%.gz}.report \
--gzip-compressed \
--paired ${i}_1.fastq.gz ${i}_2.fastq.gz > ${i%.gz}.kraken;
done

# move files generated to desire folders
mv /home2/cmmoranga/clusta/data_paired_reads/*.kraken ./Kraken
mv /home2/cmmoranga/clusta/data_paired_reads/*.report ./Kraken_report

# Move to Kraken_report folder and merge all report
#cd Kraken_report
#cat *.report > all.report

# Select 2 and 3 save
#cat all.report | cut -f 2,3 > all.kraken.krona

# Generate kornal html file
#ktImportTaxonomy all.kraken.krona
#firefox taxonomy.krona.html

