#!/usr/bin/perl -l

use warnings;
use strict;
use List::Util qw(reduce);

sub getNum {
    my $arr = $_[0];
    return int(substr( $arr->[$_[1]], $_[2], 1 ));
}

sub isInBasin {
    my $basin = $_[0];
    my $row = $_[1];
    my $col = $_[2];

    for (my $i = 0; $i < scalar @{ $basin }; $i += 2) {
        if ( $row == $basin->[$i] && $col == $basin->[$i + 1]) {
            return 1;
        }
    }

    return 0;
}

sub grow {
    my $arr = $_[0];
    my $basin = $_[1];
    my $row = $_[2];
    my $col = $_[3];

    if (getNum($arr, $row, $col) == 9) {
        return;
    }

    if (isInBasin($basin, $row, $col)) {
        return;
    }

    push(@$basin, $row);
    push(@$basin, $col);

    if ($row > 0 ) {
        grow($arr, $basin, $row - 1, $col);
    }

    if ($row < scalar @{ $basin } - 1) {
        grow($arr, $basin, $row + 1, $col);
    }

    if ($col > 0 ) {
        grow($arr, $basin, $row, $col - 1);
    }

    if ($col < length($arr->[0]) - 1 ) {
        grow($arr, $basin, $row, $col + 1);
    }
}


sub getRisk {
    my $arr = $_[0];
    my $row = $_[1];
    my $col = $_[2];
    my $basins = $_[3];
    my $l = length($arr->[0]) - 1;

    my $num = getNum($arr, $row, $col);
    if ( ( $col > 0 ?  $num < getNum($arr, $row, $col - 1) : 1 ) &&
         ( $col < length($arr->[0]) - 1 ? $num < getNum($arr, $row, $col + 1) : 1 ) &&
         ( $row > 0 ?  $num < getNum($arr, $row - 1, $col) : 1 ) &&
         ( $row < scalar @{ $arr } - 1 ? $num < getNum($arr, $row + 1, $col) : 1 ) )
    {
        my @basin = ();
        grow($arr, \@basin, $row, $col);
        push(@$basins, ($#basin + 1) / 2);
        
        return $num + 1;
    }

    return 0;
}

open(FH, '<', 'input.txt') or die $!;

my @arr = ();
while(<FH>){
    chomp($_);
    push(@arr, $_);
}

# array with size of basins
my @basins = ();
my $risk = 0;
for my $row (0..$#arr) {
    for my $col (0..length($arr[0]) - 1) {
        $risk += getRisk(\@arr, $row, $col, \@basins);
    }
}

## shameless steal
my %seen;
my @top3 = (sort { $b <=> $a }
            grep {!$seen{$_}++}
            @basins)[0..2];
my $p2 = reduce { $a * $b } @top3;

print("Day 9, part1: $risk");
print("Day 9, part2: $p2");

close(FH);
