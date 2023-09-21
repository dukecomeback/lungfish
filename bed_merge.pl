#!/usr/bin/perl -w

my $usage=<<EOF;
----------------------------------------------
Merge genome regions, regardless of strand. Revised from gff_cluster.pl

Usage: $0 input(or stdin)

Demo of input: scaffold start end

			Du Kang 2022-1-11
----------------------------------------------
EOF

use List::Util qw(max min);

while (@ARGV) {
	push @file, shift @ARGV;
}
die $usage if (!@file and -t STDIN);

open IN, "cat @file |sort -T ./ -k1,1V -k2,2n |uniq |" or die $!;
$pre_scaf="initiate";
while(<IN>){
	next if /^\s*$/;
	chomp;
	@_=split /\s+/, $_;
	$cur_scaf=$_[0];
	($s,$e)= $_[1]<$_[2]? ($_[1],$_[2]) : ($_[2],$_[1]);
	$cur_range="$s..$e";

	if ($cur_scaf eq $pre_scaf and &overlap($cur_range,$accum_range)) {	# 重合，加入cluster
		$accum_range .= "_$cur_range";
		
	}else{									# 不重合，output and initialize
		if ($accum_range) {
			my @range=split /\_|\.\./, $accum_range;
			my $min=min @range;
			my $max=max @range;
			print "$pre_scaf\t$min\t$max\n";
		}
		$accum_range=$cur_range;
	}

	$pre_scaf=$cur_scaf;
}
close IN;

# 最后一次输出
my @range=split /_|\.\./, $accum_range;
my $min=min @range;
my $max=max @range;
print "$pre_scaf\t$min\t$max\n";

######################################### subs ##########################################
sub overlap{
	# I eat in two region strings, the query could only be one region while the subject could be multiple regions
	# eg: &overlap(1..3, 5..8_2..4)
	my $query=shift @_;
	my $subject=shift @_;
	my ($a,$b)= $query=~/(\d+)\.\.(\d+)/;
	my $overlap=0;
	foreach $i (split /_/, $subject){
		my ($s,$e)= $i=~/(\d+)\.\.(\d+)/;
		unless ($a>$e+1 or $b<$s-1){$overlap=1; last}
	}
	return $overlap;
}
