# Preface
This is a quick followup to my other guide where I explained how to route PulseAudio through JACK using the QJackCtl GUI. 
The following walkthrough is intended for those who wish to permanently use their PulseAudio-through-JACK configuration as created in the original guide. It will introduce a minimalistic approach based on config files and command line tools mostly.  
This guide is for advanced users, it might miss some trivial details here and there.

# Setup
## Package requirements
The following requirements of the original guide still apply:

    jack2 (aka jackd2), calf (aka calf-plugins), pulseaudio-module-jack

Additonally, we need the command line tool `jack-plumbing`. For Debian systems this is part of the package:

    jack-tools

## Config requirements
### 1. Calf config
You should have set up an EQ as instructed in the original guide and have your Calf rack configuration saved in `~/.config/jack/calf.conf`

### 2. Plumbing config
Instead of using the Patchbay GUI, we will set up the JACK connections via command line this time. We will make use of a rules file for the tool `jack-plumbing`:
- edit `~/.config/jack/rules`:
    ```
    (connect "PulseAudio JACK Sink:front-left" "Calf Studio Gear:eq5 In #1")
    (connect "PulseAudio JACK Sink:front-right" "Calf Studio Gear:eq5 In #2")
    (connect "Calf Studio Gear:eq5 Out #1" "system:playback_1")
    (connect "Calf Studio Gear:eq5 Out #2" "system:playback_2")
    ```
    You can get the names of the plugs by using the **Connect** button of the Calf EQ module and having a look at the list of the available ports.

## Startup script
Finally, this script is to be added to autostart:
```
#!/bin/bash

# start the JACK daemon
jackd -ndefault -dalsa -dhw:PCH -r44100 -p1024 -n2 &
sleep 1

# connect PulseAudio to it
pactl load-module module-jack-sink channels=2 connect=0
pactl set-sink-volume jack_out 75%
pactl set-default-sink jack_out

# start and connect the EQ
calfjackhost --load ~/.config/jack/calf.conf &
jack-plumbing -o ~/.config/jack/rules &
```
The `jackd` startup command is the same as in your `~/.jackdrc` file created by QJackCtl when you configure it using the GUI.  
Don't forget to `chmod +x ~/.config/jack/startup.sh`!