#!/usr/bin/perl -l

use warnings;
use strict;
use List::Util qw(min);
use List::Util qw(max);

sub expand {
    my $arr = $_[0];
    my $i = $_[1];
    my $j = $_[2];

    for my $ii (max(0,$i-1)..min(9,$i+1)) {
        for my $jj (max(0,$j-1)..min(9,$j+1)) {
            if ( $arr->[$ii][$jj] == 9 ) {
                $arr->[$ii][$jj] += 1;
                expand($arr, $ii, $jj);
            } elsif ( $arr->[$ii][$jj] < 9 ) {
                $arr->[$ii][$jj] += 1;
            }
        }            
    }
}

sub increment {
    my $arr = $_[0];
    for my $i (0..9) {
        for my $j (0..9) {
            if ( $arr->[$i][$j] == 9 ) {
                $arr->[$i][$j] += 1;
                expand($arr, $i, $j);
            } elsif ( $arr->[$i][$j] < 9 ) {
                $arr->[$i][$j] += 1;
            }
        }
    }
}

sub clean {
    my $arr = $_[0];
    my $flashes = 0;
    for my $i (0..9) {
        for my $j (0..9) {
            if ( $arr->[$i][$j] == 10 ) {
                $arr->[$i][$j] = 0;
                $flashes += 1;
            }
        }
    }

    return $flashes;
}

sub show {
    my $arr = $_[0];
    $"="";
    for my $i (0..9) {
        print( @{$arr->[$i]} );
    }
    print("- - - - -");
}

open(FH, '<', 'input.txt') or die $!;

my @arr = ();
my $i = 0;
while(<FH>){
    chomp($_);

    for my $j (0..9) {
        $arr[$i][$j] = int(substr($_, $j, 1));
    }

    $i += 1;
}

show(\@arr);

my $flashes = 0;
my $flashing = 0;
for my $i (1..500) {
    increment(\@arr);
    my $flashing = clean(\@arr);

    if ($flashing == 100) {
        print("Day 11, part1: ", $flashes);
        print("Day 11, part2: ", $i);
        last;
    }

    if ($i <= 100) {
        $flashes += $flashing;
    }

    show(\@arr);
}

close(FH);
