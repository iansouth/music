#!/bin/bash

OUTPUT=`./extract_device.sh "Built-in Output"`
INPUT=`./extract_device.sh "Built-in Input"`
LAUNCHPAD=`./extract_midi.sh "Launchpad"`

killall chuck
sleep 1
chuck --loop --dac:$OUTPUT --adc:$INPUT &
sleep 1
chuck + mindwerks_osc.ck
sleep 1
chuck + mindwerks_audio.ck

echo "Don't close me!" > /Users/ian/nnnn.txt
open -e -W /Users/ian/nnnn.txt