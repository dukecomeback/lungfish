# lungfish
codes used in lungfish program

## retrieveHomo.sh
Ensembl API used for retrieving piGenes from different species
to retrieve that from NCBI, use `esearch -db gene -query "MAEL" |efilter -query "Protopterus annectens" |efetch -format fasta`

## shrink_genome.sh
Shrink genome by keeping only regions referred in file "contig.bed"
