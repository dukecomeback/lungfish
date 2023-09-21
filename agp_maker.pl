#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
I make agp file

Usage: $0 input(or stdin) (-n 240)

-n 	length of gap (Ns) link each contig, default 240

Demo of input:
scaf_0	ptg014912l_1	1	2089552	+
scaf_1	ptg013503l_1	1	5356873	+
scaf_1	ptg012543l_1	1	2997027	+
scaf_1	ptg004553l_1	1	9681068	-

* you need to reversly sort the coordinates on the reverse strand when the contigs are broken down
* dim_up |print \$F[0]."\\t".join("\\t",reverse \@F[1..\@F-1]) |dim_down 

			Du Kang 2021-12-27
----------------------------------------------
EOF

$n=240;
while ($_=shift @ARGV) {
	if (/^-n$/) {
		$n=shift @ARGV;
	}elsif (!/^-/) {
		push @file, $_;
	}
}
die $usage if (!@file and -t STDIN);

$pre="";
open IN, "cat @file |" or die $!;	# if @file was none, will be read from STDIN
while(<IN>){
	next if /^\s*$/;
	@F=split;
	if ($F[0] ne $pre) {
		$end=0;
		$l=1;
	}else{
		print "$F[0]\t$start\t$end\t$l\tN\t$n\tscaffold\tyes\tna\n";
		$l++;
	}
	$start=$end+1;
	$end=$start+$F[3]-$F[2];
	print "$F[0]\t$start\t$end\t$l\tW\t$F[1]\t$F[2]\t$F[3]\t$F[4]\n";
	$l++;
	$start=$end+1;
	$end=$start+$n-1;
	$pre=$F[0]
}
