use v6;

############################################################################################################
# Strategy is to push all opening parens to a stack. When a closing parens is received, we try to
# match it against the last stack element. If it is not a match, then line is deemed corrupted and
# we add it to the error score (part 1); if it is a match, we just pop from stack.
#
# Once all characters from a line are read, we check if line is incomplete (i.e, stack is not empty)
# so we compute the completion score.
############################################################################################################

####################################
# Part 1 utility functions
####################################
sub getErrorScore($c) {
    if    $c eq ")"  { return 3; }
    elsif $c eq "]"  { return 57; }
    elsif $c eq "\}" { return 1197; }
    else             { return 25137; }
}

sub compareToTail($tail, $c) {
    return (( $tail eq "\{" && $c eq "\}" ) ||
            ( $tail eq "["  && $c eq "]" )  ||
            ( $tail eq "("  && $c eq ")" )  ||
            ( $tail eq "<"  && $c eq ">" ));
}

sub isClosingChar($c) {
    return ( ( $c eq "}" ) ||
             ( $c eq "]" ) ||
             ( $c eq ")" ) ||
             ( $c eq ">" ) );
}

####################################
# Part 2 utility functions
####################################

sub getPoints($c) {
    if $c    eq "("   { return 1; }
    elsif $c eq "["   { return 2; }
    elsif $c eq "\{"  { return 3; }
    else              { return 4; }
}

sub computeCompletionScore(@stack) {
    my $prize = 0;
    for @stack.reverse -> $c {
        $prize *= 5;
        $prize += getPoints($c);
    }

    return $prize;
}

my $file  = open 'input.txt';

# part 1
my $errorScore = 0;

# part 2
my @completionScores;

for $file.lines -> $line {
    next unless $line; # ignore any empty lines 

    my $error=False;
    my @stack;
    loop (my $i = 0; $i < $line.chars; $i++) {
        my $c = substr($line, $i, 1);

        if @stack.elems > 0 && isClosingChar($c) {
            if compareToTail(@stack.tail, $c) {
                @stack.pop();
            } else {
                $error=True;
                $errorScore += getErrorScore($c);
                last;
            }
        } else {
            push(@stack, $c);
        }
    }

    if ! $error { push(@completionScores, computeCompletionScore(@stack)); }
}

say "Day 10, part1: ", $errorScore;

my $index = ((@completionScores.elems - 1) / 2);
say "Day 10, part2: ", @completionScores.sort[$index]
