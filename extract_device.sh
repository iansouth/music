#!/bin/bash

chuck --probe 2>&1 | grep -m 1 -B1 "$1" | head -1 | grep -o '[0-9][0-9]*'

