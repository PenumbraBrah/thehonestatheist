#!/bin/bash

W=$(identify -format '%w' $1)
H=$(identify -format '%h' $1)

if [ $W = $H ]; then
    convert $1 -resize 300x300 $1
    convert $1 -modulate 100,$2 $1
else
    echo Dimensions are not square
    echo Should we attempt to center crop?
    read cropans
    if [ $cropans = "yes" -o $cropans = "y" -o $cropans = "true" ]; then
        [[ $W -lt $H ]] && L=$W || L=$H

        D=`expr $W - $H`

        if [[ $D -lt 0 ]]; then
            (( D=$D * -1 ))
        fi

        if [[ $H -gt $W ]]; then
            hh="+0+"
        fi

        (( E=$D / 2 ))
        echo convert $1 -crop $(echo $L)x$L+$(echo $hh)$E $1
        convert $1 -crop $(echo $L)x$L+$(echo $hh)$E $1
        convert $1 -resize 300x300 $1
        convert $1 -modulate 100,$2 $1
    fi
fi
