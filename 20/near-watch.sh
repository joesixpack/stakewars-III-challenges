#!/bin/bash

source ~/.profile

export seatprice=$(near validators next | grep seat | tail -n 1 | awk '{print $7}' | sed 's/[^0-9]*//g')
#export valset=$(near proposals | tail -n +5 | head -n -4 | sed 's/|//g' | sed 's/=>//g' | tr -s ' ' | egrep -v "Declined|Kicked")
#export estseatprice=$(echo "${valset}" | head -n 400 | tail -n 1 | awk '{print match($5, /[^ ]/) ? $5 : $3}' | sed 's/[^0-9]*//g')

watch -t 'echo "Next Epoch Seat Price: $seatprice" ; #echo "Estimated Seat Price: $estseatprice" ;
echo "\nCurrent Epoch Status"; near validators current  | grep "$NEAR_POOL\|sierra" ;
echo "\nNext Epoch Status"; near validators next  | grep "$NEAR_POOL\|sierra" ;
echo "\nEpoch After Next Status"; near proposals  | grep "$NEAR_POOL\|sierra"  ;
./near-watch2.sh'
