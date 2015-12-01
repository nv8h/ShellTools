#!/bin/sh
LINE=`xrandr -q | grep Screen`
#echo LINE = ${LINE}
WIDTH=`echo ${LINE} | awk '{ print $8 }'`
#echo WIDTH = ${WIDTH}
HEIGHT=`echo ${LINE} | awk '{ print $10 }' | awk -F"," '{ print $1 }'`
#echo HEIGHT = ${HEIGHT}

RESOLUTION=${WIDTH}x${HEIGHT}

FLAGS=--input /usr/lib/x86_64-linux-gnu/mupen64plus/mupen64plus-input-sdl.so

echo "mupen64plus ${FLAGS} --resolution ${RESOLUTION} \"${1}\"\n" >> ~/Asztal/run.log
mupen64plus ${FLAGS} --resolution ${RESOLUTION} "${1}"
