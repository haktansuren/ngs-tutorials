# ReadsAnnotbyBaitProx
This perl script is to annotate markers (reads) data based on the annotation file (gff map) provided. Three level of categorization "On", "Near" and "Off" is used for each reads based on their respective proximity to the annotation.

This script is helpful categorizing the reads from NGS data based on the bait position in sequence capture studies. Figure 1 from [this](http://onlinelibrary.wiley.com/doi/10.1111/1755-0998.12570/full) paper generated using the output from this script. 

**Third** argument (set it to 500 in example below ) in the script is used to determine "Off" category.  

**Usage:**
```sh
perl ReadsAnnotbyBaitProx.pl baits.gff reads.txt 500 > out.txt 
```