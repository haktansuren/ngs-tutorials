#!/usr/bin/perl
# Usage perl ReadsAnnotbyBaitProx.pl baits.gff reads.txt 500 > out.txt

use strict;
use Data::Dumper;

my $sep = "\t";
my $prox_limit = $ARGV[2]; #length for labelling nearby probes


open (MYFILE1, $ARGV[0]);
open (MYFILE2, $ARGV[1]);

my $header1 = <MYFILE1>;
chomp $header1;

my $i = 1;
my %probes;
while (<MYFILE1>) {
    chomp;
    my @arr = split /$sep/, $_;
    
    next if ($arr[0] =~ /^#+$/);
    
    my $ident;
    
    if ( $arr[8] =~ /identity=([0-9]*\.?[0-9]*)/ ){
        $ident = $1;
    }else{
        next;
    }
    
    #print $ident."\n";
    #next if ($ident <= 90); #if you want
    
    #print Dumper(\@arr); die; 
    
    my %poses = (
        "start"  => $arr[3],
        "end" => $arr[4],
        "id" => $ident
    );
    
    push @{$probes{$arr[0]}}, \%poses;
         
    $i++;
}

my $j = 1;
my %result;
print "Markers\tPosition\tID%\tAnnot\tStart\tEnd\tDistance\n";
while (<MYFILE2>) {
    chomp;
    my @arr = split /$sep/, $_;
   
    my $ident = 0;
    my $start = 0;
    my $end = 0;
    if ( $probes{$arr[0]} ){
	my $atleastprox = 0;
	my ($minstart,$minend);
	my $mindiff = 0+'inf';
        foreach my $p (@{$probes{$arr[0]}}){
            $ident = $p->{'id'};
	    $start = $p->{'start'};
	    $end = $p->{'end'};
            
	    if ( abs($arr[1] - $start) < $mindiff ){
		$mindiff = abs($arr[1] - $start);
		$minstart = $start;
		$minend = $end;
	    }
	    
	    if ( abs($arr[1] - $end) < $mindiff ) {
		$mindiff = abs($arr[1] - $end);
		$minstart = $start;
		$minend = $end;
	    }

	    if ($arr[1] >= $p->{'start'} && $arr[1] <= $p->{'end'}) {
                #print "$arr[0] is in between $p->{'start'} and $p->{'end'}: $arr[1] -- in\n";
                $result{$arr[0]."__".$arr[1]} = 'in';
                print "$arr[0]\t$arr[1]\t$ident\tOn\t$start\t$end\t$mindiff\n";
		$atleastprox = 0;
                last;
            }elsif ($arr[1] >= $p->{'start'} - $prox_limit && $arr[1] <= $p->{'end'} + $prox_limit ){
                $atleastprox = 1;
            }else{
		#notin
            }
        }

	if ($atleastprox > 0){
		$result{$arr[0]."__".$arr[1]} = 'prox';
		print "$arr[0]\t$arr[1]\t$ident\tNear\t$minstart\t$minend\t$mindiff\n";
	}elsif (!$result{$arr[0]."__".$arr[1]}) {
            #$result{$arr[0]."__".$arr[1]} = 'off';
            print "$arr[0]\t$arr[1]\t$ident\tOff\t$minstart\t$minend\t$mindiff\n";
        }
        
    }else{
        #print "We could not find $arr[0] in probe list\n";
        print "$arr[0]\t$arr[1]\t$ident\tOff\t$start\t$end\t0\n";
    }
    
    $j++;
}