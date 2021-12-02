## Goal #1
# count the number of times a depth measurement
# increases from the previous measurement. 
# (There is no measurement before the first measurement.)
#
# Goal #2
# Considering every single measurement isn't as useful as you
# expected: there's just too much noise in the data.
# Instead, consider sums of a three-measurement sliding window.
#
# Your goal now is to count the number of times the sum of
# measurements in this sliding window increases from the previous sum.
{
    if ( p && $0 > p ) ret++
    p=$0

    if ( FNR == 1 ) { sum[0] += $0; ix[0]++; next }

    for (i=0; i<=1; ++i) {
        if ( ix[i] == 2 ) {
            if ( PREV && (sum[i] + $0) > PREV )
                ret2++;
            PREV=sum[i]+$0
            sum[i]=0
            ix[i]=0
        }

        sum[i]+=$0
        ix[i]++
    }
} 

END { print ret; print ret2 }
