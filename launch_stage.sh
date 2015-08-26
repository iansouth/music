#!/bin/bash

OUTPUT=`./extract_device.sh "Built-in Output"`
INPUT=`./extract_device.sh "Built-in Input"`
LAUNCHPAD=`./extract_midi.sh "Launchpad"`

killall chuck
sleep 1
chuck --loop --dac:$OUTPUT --adc:$INPUT &
sleep 1
chuck + lick-import.ck
sleep 1
chuck + effects/drone_stack.ck
