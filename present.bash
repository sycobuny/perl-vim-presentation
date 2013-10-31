#!/bin/bash

# find out where this script is living to pretend it's ~. this both pretties
# up our display and tricks vim into using the project-local .vimrc *only*,
# for consistent "look and feel".
root=$(dirname "$BASH_SOURCE")

# set some environment variables to make display prettier. this mostly works
# well with oh-my-zsh themes like "cloud".
SLIDES=$root/slides
MODLIB=$root/lib

# back up current location to return to later, and cd to this project's root.
cwd=`pwd`
cd $root

# start a new session and sleep for a moment. the settings seem to take
# better when we rest before setting them
tmux new-session -d -s presentation
sleep 0.4s

# take off the status bar
tmux set-option -q -t presentation status off

# do some command-line injections to set up our ENV. the sleep is necessary or
# clear-history won't clear the `clear` command.
tmux send-keys -t presentation:0.0 "export REAL_HOME=$HOME" Enter
tmux send-keys -t presentation:0.0 "export HOME=$root"      Enter
tmux send-keys -t presentation:0.0 "export SLIDES=$SLIDES"  Enter
tmux send-keys -t presentation:0.0 "export MODLIB=$MODLIB"  Enter
tmux send-keys -t presentation:0.0 clear Enter
tmux send-keys -R -t presentation:0.0
sleep 0.4s
tmux clear-history -t presentation:0.0

# attach. from here on out, a controller should take over.
tmux attach -t presentation

# by now we've exited the presentation, and we can go back home.
cd $cwd
