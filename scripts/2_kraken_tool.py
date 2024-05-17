import os
import sys
import subprocess
import string
import random

bashfile=''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
bashfile='/tmp/'+bashfile+'.sh'

f = open(bashfile, 'w')
s = """#! /usr/bin/env bash

##create a kraken environment
#mamba create -n krakenx kraken2 taxpasta
#Activate environment
source activate krakenx

##for paired-end data - provide the working directory as an argument. 
workdir=$1

datadir="$workdir"/raw_data
outdir="$workdir"/results
scriptdir="$workdir"/scripts
PathogenDB="$workdir"/PathogenDB

cd $datadir
## Loop through to run all files concurrently
for i in `ls *.gz | sed -e 's/\\_[12].fastq.gz//' | sort | uniq`; do
kraken2 --threads 4 \
--db $PathogenDB/ \
--report ${outdir}/${i}.report \
--gzip-compressed \
--paired ${i}_1.fastq.gz ${i}_2.fastq.gz > ${outdir}/${i}.kraken
done

## move files generated to desire folders and merge all report
cd $outdir
taxpasta merge \
	--profiler kraken2  \
	--output-format tsv \
	--add-name \
	--add-rank \
	--taxonomy $PathogenDB/taxonomy/latest \
	-o testdata_merged_kreports.tsv \
	*.report


# Generate PDF Report
export PATH="/Library/Frameworks/R.framework/Resources:$PATH"
Rscript -e "rmarkdown::render('$scriptdir/cgenomics_kreport.Rmd')"

"""
f.write(s)
f.close()
os.chmod(bashfile, 0o755)
bashcmd=bashfile
for arg in sys.argv[1:]:
  bashcmd += ' '+arg
subprocess.call(bashcmd, shell=True)
