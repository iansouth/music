#!/bin/bash

chuck --probe 2>&1 | grep -m 1 $1 | sed 's/.*\[\([0-9]\)].*/\1/'
