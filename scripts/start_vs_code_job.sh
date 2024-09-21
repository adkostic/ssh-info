#!/bin/bash

#SBATCH -p priority
#SBATCH -c 8
#SBATCH --mem=24G
#SBATCH -t 12:00:00 #### -t 1-12:00:00  # Specifies 1 day and 12 hours
#SBATCH --job-name="vscodetunnel"

# Load necessary modules if needed
# ~/.bashrc

# Sleep for the duration of the job
sleep 12h  # Adjust as needed # sleep 12h==12 hours # sleep 2d  # Sleeps for 2 days  sleep 30m for 30 minutes, etc.
