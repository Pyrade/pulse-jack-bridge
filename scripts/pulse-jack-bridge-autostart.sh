#!/bin/bash

# startup JACK if it isn't running
if [ -z `pidof jackd` ]
then
    pulseaudio --kill
    jackd -ndefault -dalsa -dhw:0 -r44100 -p1024 -n2 > ~/.config/jack/jackd.log 2>&1 &
    # wait for JACK to be up and running
    jack_wait -w
    pulseaudio --start
fi

# connect PulseAudio to JACK
pactl load-module module-jack-sink channels=2 connect=0
pactl set-sink-volume jack_out 85%
pactl set-default-sink jack_out

# start EQ and Connector if not already running
[ -z `pidof calfjackhost` ] && calfjackhost --load ~/Scripts/pulse-jack-bridge/calf.conf &
[ -z `pidof jack-plumbing` ] && jack-plumbing -o ~/Scripts/pulse-jack-bridge/rules &
xdotool search --sync --onlyvisible --classname "Calf JACK Host - session: Calf Studio Gear" | xargs wmctrl -i -c &
exit