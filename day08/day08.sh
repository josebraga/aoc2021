#!/usr/bin/env bash

echo "Day 8, part1: $( cut -d'|' -f2 input.txt | tr ' ' '\n' | sed '/^$/d' | grep -vE '\b[a-z]{5}\b|\b[a-z]{6}\b' | wc -l )"

## Utilities
get_common() {
    echo $( comm -12 <(fold -w1 <<< "$1" | sort -u) <(fold -w1 <<< "$2" | sort -u) | tr -d '\n' )
}

equal() {
    comm -3 <(fold -w1 <<< "$1" | sort -u) <(fold -w1 <<< "$2" | sort -u) | tr -d '\n'
}

sorted() {
    fold -w1 <<< "$1" | sort -u | tr -d '\n'
}

contains() {
    [[ "$( get_common $1 $2 )" = "$2" ]]
}

grab_words_with_size() {
    echo $first | grep -oE "\b\w{$1}\b"
}

## Parse numbers from left-hand side
parse_numbers() {
    # ONE
    NUMBERS[1]=$( sorted $( grab_words_with_size 2 ) )

    # SEVEN
    NUMBERS[7]=$( sorted $( grab_words_with_size 3 ) )

    # FOUR
    NUMBERS[4]=$( sorted $( grab_words_with_size 4 ) )

    # EIGHT
    NUMBERS[8]=$( sorted $( grab_words_with_size 7 ) )

    # THREE
    for word in $( echo $@ | grep -oE '\b\w{5}\b' ); do
        if contains $word ${NUMBERS[1]}; then
            NUMBERS[3]=$( sorted $word )
        fi
    done

    # SIX
    for word in $( echo $@ | grep -oE '\b\w{6}\b' ); do
        if ! contains $word ${NUMBERS[1]}; then
            NUMBERS[6]=$( sorted $word )
        fi
    done

    # NINE
    for word in $( echo $@ | grep -oE '\b\w{6}\b' ); do
        if contains $word ${NUMBERS[4]}; then
            NUMBERS[9]=$( sorted $word )
        fi
    done

    # ZERO
    for word in $( echo $@ | grep -oE '\b\w{6}\b' ); do
        word=$( sorted $word )
        if [[ "$word" != "${NUMBERS[6]}" && "$word" != "${NUMBERS[9]}" ]]; then
            NUMBERS[0]=$( sorted $word )
        fi
    done

    # FIVE, TWO
    for word in $( echo $@ | grep -oE '\b\w{5}\b' ); do
        word=$( sorted $word )
        if [[ "$word" != "${NUMBERS[3]}" ]]; then
            if contains ${NUMBERS[9]} $word; then
                NUMBERS[5]=$( sorted $word )
            else
                NUMBERS[2]=$( sorted $word )
            fi
        fi
    done
}


## Compute number from right-hand side
compute_number() {
    sum=0
    mult=1000
    for word in $@; do
        for (( i=0; i<10; i++ )); do
            if [[ $( equal ${NUMBERS[$i]} $word ) == "" ]]; then
                sum=$((sum + mult*i))
                mult=$((mult / 10))
            fi
        done
    done
    echo $sum
}

TOTAL_SUM=0
while read -r line; do
    first=$( echo $line | cut -d'|' -f1 )
    parse_numbers $first

    last=$( echo $line | cut -d'|' -f2 )
    value=$( compute_number $last )
    TOTAL_SUM=$((TOTAL_SUM + value))
done < "input.txt"

echo "Day 8, part2: $TOTAL_SUM"
