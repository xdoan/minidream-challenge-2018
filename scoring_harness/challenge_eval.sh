#!/usr/bin/env bash

# Automation of validation and scoring
script_dir=$(dirname $0)
if [ ! -d "$script_dir/log" ]; then
  mkdir $script_dir/log
fi
source /home/shared_mnik_xdo/miniconda2/bin/activate /home/shared_mnik_xdo/miniconda2/envs/minidream


#---------------------
# Validate submissions
#---------------------
# Remove --send-messages to do rescoring without sending emails to participants
# python $script_dir/challenge.py -u "synapse user here" --send-messages --notifications validate --all >> $script_dir/log/score.log 2>&1

#--------------------
# Score submissions
#--------------------
python $script_dir/challenge.py -u "xdoan" -u "mnikolov" --send-messages --notifications score --all >> $script_dir/log/score.log 2>&1
