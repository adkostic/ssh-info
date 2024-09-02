#!/bin/bash

#SBATCH -p priority
#SBATCH -c 6
#SBATCH --mem=16G
#SBATCH -t 2:00:00 #### -t 1-12:00:00  # Specifies 1 day and 12 hours
#SBATCH --job-name="vscodetunnel"

# Load necessary modules if needed
# ~/.bashrc

# Sleep for the duration of the job
sleep 2h  # Adjust as needed # sleep 12h==12 hours # sleep 2d  # Sleeps for 2 days  sleep 30m for 30 minutes, etc.
