#!/usr/bin/env bash

NUMBERS=$( head -n 1 input.txt | sed 's|,| |g' )

sed '1,2d' input.txt > copy.txt

# flatten cards
perl -l -p -e 'BEGIN {$/="";  $\="\n\n"}; s/\n/ /mg' copy.txt > cards.txt

# remove empty lines
sed -i "/^$/d" cards.txt


# Look for Bingo! in the cards
isBingo() {
    awk '{
             for (i=0; i<5; i++) {
                 row=0
                 for (j=1; j<=5; j++) {
                     ix = i * 5 + j
                     if ($ix=="x") row++;
                 }

                 col=0
                 for (j=0; j<5; j++) {
                     ix= i + 1 + j * 5
                     if ($ix=="x") col++;
                 }

                 if (row==5 || col==5)
                 print NR
             }
         }' cards.txt
}


# Fill in the cards when number is matched
replace() {
    sed -i -E "s|\b$1\b|x|g" cards.txt
}


# Main Loop
for n in $NUMBERS; do
    # replace number with 'x' in all cards
    replace $n

    # get all lines with bingo!
    bingo_lines=$( isBingo )
    if [[ $bingo_lines ]]; then
        echo -e "\n# --> Bingo with $n!"
        str="";
        for ln in $bingo_lines; do
            # trim, remove x and replace spaces with + for summation
            SUM=$( sed -n "$ln p" cards.txt | sed 's|x||g' | sed 's|^ *||g' | sed 's| *$||g' | sed 's|  *| |g' | sed 's| |+|g' | bc )
            echo "Total: " $( echo "$SUM * $n" | bc )

            # record which lines should be deleted
            str="$str$ln d;"
        done

        # remove cards
        sed -i "$str" cards.txt
    fi
done

rm cards.txt copy.txt

