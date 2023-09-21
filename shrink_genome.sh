#!/bin/bash
function usage(){
echo "
I shrink large genome by keeping target regions (extend 600bp, link with 240x\"N\"). nohup me

Usage: $0 contig.bed contig.len contig.fna scaf.agp

demo of contig.bed: scaf start end

cat ab_homo.gff.info_add.filter |perl -lane 'print /\t/? \"\$_\\t\$F[0]:\$F[3]\$F[6]\$F[4]\" : \"\$_\"' |agp_lift.pl -a ../../shrink_genome.2scaf.agp |perl -aF'\t' -lne 'if(\$F[-1]=~/\\S+?:(\\d+).*[+-](\\d+)\$/){(\$F[3],\$F[4])=(\$1,\$2);\$F[0]=~s/^S//;print join(\"\t\",@F[0..@F-3])}else{print}' >ab_homo.gff.info_add.filter.lift
	# lift annotation back to giant assembly

	Du Kang 2022-1-13
"
}

if [ ! -n "$1" ]; then
	usage
	exit
fi

bed=$1
len=$2
fna=$3
agp=$4

join.pl $bed $len |perl -lane '($s,$e)= $F[1]<$F[2]? ($F[1],$F[2]) : ($F[2],$F[1]); $ns=$s-600>1? $s-600 : 1; $ne=$e+600<$F[-1]? $e+600 : $F[-1]; print "$F[0]\t$ns\t$ne"' |dispatch -id 0
	# extend 600 bp
ls hehe.*[0-9] |perl -lane 'print "bed_merge.pl $_ >$_.bed"' |bsub -w 
cat hehe.*bed >merged.bed
rm hehe.*
clean

cat merged.bed |perl -lane 'print "$F[0]\t$F[1]..$F[2]"' |dim_up >merged.bed.dim_up

cat $agp |perl -lane 'next unless $F[4] eq "W";$o=join(";",@F);print "$o\t$F[5]"' |join.pl -1 merged.bed.dim_up |cut -f1,3- |grep -Pv '\t-$' |perl -lane 'print $F[0]=~/\+$/? $_ : $F[0]."\t".join("\t",reverse @F[1..@F-1])' |dim_down |perl -lape 's/;/\t/g;s/\.\./\t/g' |perl -lane 'if ($F[-2]>=$F[-5] and $F[-1]<=$F[-4]){print "S$F[0]\t$F[5]\t$F[-2]\t$F[-1]\t$F[-3]"}' |agp_maker.pl >shrink_genome.agp
	# pay attion to the reverse @F here when it is on the "-" strand !!!

cat shrink_genome.agp |perl -lane 'print "$F[0]\t$F[1]\t$F[2]\t$F[3]\t$F[4]\t$F[5]:$F[6]$F[8]$F[7]" if $F[4] eq "W"' |agp_lift.pl -a $agp bak |perl -lane '$F[-1]=~/(\S+):(\d+)([+-])(\d+)/;print "$F[0]\t$F[1]\t$F[2]\t$F[3]\t$F[4]\t$1\t$2\t$4\t$3"' >shrink_genome.2scaf.agp

echo "agp2fa.pl shrink_genome.agp -seq $fna >shrink_genome.fna " |bsub -h -w
