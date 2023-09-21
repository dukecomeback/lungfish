while read -r gene
do
	export gene
	wget -q --header='Content-type:text/xml' "https://rest.ensembl.org/homology/symbol/human/${gene}?format=condensed;type=orthologues"  -O - |grech -q species.list |perl -lane '/homologies id="(.*?)".*species="(.*?)"/;print "$ENV{gene}__$2\t$1"' 
done < "gene.list"
