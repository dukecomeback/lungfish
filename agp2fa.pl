#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
Feed me agp file and the contigs, I output scaffold sequences.

Usage: $0 input.agp(or stdin) -seq contig.fa >scaffold.fa

			Du Kang 2021-12-17
----------------------------------------------
EOF

while ($_=shift @ARGV) {
	if (/^-seq$/) {
		$contig=shift @ARGV;
	}elsif (!/^-/) {
		push @agp, $_;
	}
}
die $usage if (!@agp and -t STDIN);

open FA, $contig or die $!;
while (<FA>) {
	if (/>(\S+)/) {
		$name=$1;
	}else{
		chomp;
		$seq{$name}.=$_;
	}
}
close FA;

open AGP, "cat @agp|" or die $!;
open OUT, "| fold";
$pre="";
while (<AGP>) {
	@F=split;
	if ($F[0] ne $pre) {print OUT $pre? "\n>$F[0]\n" : ">$F[0]\n"}
	$pre=$F[0];
	if ($F[4] eq "N") {
		$out="N"x$F[5];
	}else{
		$l=$F[7]-$F[6]+1;
		$out=substr($seq{$F[5]},$F[6]-1,$l);
		$out =~ tr /atcgATCG/tagcTAGC/ and $out = reverse $out if $F[8] eq "-"; 
	}
	print OUT "$out";
}
print OUT "\n";
close AGP;
close OUT;

