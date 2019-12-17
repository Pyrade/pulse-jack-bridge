#!/bin/bash
pactl load-module module-jack-sink channels=2 connect=0
pacmd set-default-sink jack_out 85%
pacmd set-default-source jack_in
