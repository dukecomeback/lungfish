#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
I lift the coordinates according to a agp file

Usage: $0 input(or stdin) -a input.agp (bak/for)

	-a	agp file
	-bak	contig as the query, by default scaffold is the query

demo of input:	blablabla scaffold:start(+/-)end

			Du Kang 2021-12-20
----------------------------------------------
EOF

use IntervalTree;

$bak=0;
while ($_=shift @ARGV) {
	if (/^(-*)bak$/) {
		$bak=1;
	}elsif(/^-a$/) {
		$agp=shift @ARGV;
	}elsif (!/^-/) {
		push @file, $_;
	}
}
die $usage if (!@file and -t STDIN);

open AGP, $agp or die $!;
while (<AGP>) {
	#chr_1	1	5926484	1	W	ptg006026l_1	1	5926484	+
	@F=split;
	next unless $F[4] eq "W";
	if ($bak) {
		${$F[5]} //= IntervalTree->new();
		${$F[5]} -> insert($F[6],$F[7],"$F[6];$F[7];$F[0];$F[1];$F[2];$F[-1]");
	}else{
		${$F[0]} //= IntervalTree->new();
		${$F[0]} -> insert($F[1],$F[2],"$F[1];$F[2];$F[5];$F[6];$F[7];$F[-1]");
	}
}
close AGP;

open IN, "cat @file |" or die $!;
while(<IN>){
#	scaffold:start(+/-)end
	print and next if /^\s*$/;
	chomp;
	@F=split /\s+/, $_;
	($scaf,$s,$str,$e)=$F[-1]=~/(.*?):(\d+)([+-])(\d+)/ or print "$_\n" and next;
	if (!${$scaf}) {print STDERR "Warning: No records for $scaf\n"; print "$_\t-\n"; next}
	$lift= ${$scaf}->find($s,$e);
	if (!@$lift) {print STDERR "Warning: No lift region for $F[-1]\n"; print "$_\t-\n"; next}

	foreach (@$lift){
		my ($qs,$qe,$sub,$ss,$se,$STR)=/(\d+);(\d+);(.*?);(\d+);(\d+);([+-])/;

		my $dis_s= $s<=$qs? 0 : $s-$qs;
		my $dis_e= $e>=$qe? $qe-$qs : $e-$qs; 
		my $s_out= $STR eq "+"? $ss+$dis_s : $se-$dis_s;
		my $e_out= $STR eq "+"? $ss+$dis_e : $se-$dis_e;
		($s_out,$e_out)= $s_out<=$e_out? ($s_out,$e_out) : ($e_out,$s_out);

		my $str_out= $str eq $STR? "+" : "-";
		$out.="$sub:$s_out$str_out$e_out;";
	}

	chop $out;
	print "$_\t$out\n";
	$out="";
}
