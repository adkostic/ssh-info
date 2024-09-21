#!/bin/bash

# Variables
CONTROL_PATH="$HOME/.ssh/controlmasters/%r@%h:%p"
SSH_CONFIG_DIR="$HOME/.ssh/config.d"
SBATCH_SCRIPT_PATH="/home/adk9/gh_repos/ssh-info/scripts/start_vs_code_job.sh"  # Adjust the path if needed
REMOTE_WORK_DIR="/home/adk9/gh_repos"  # Adjust to your desired remote directory

# Function to execute an SSH command with the control master socket
ssh_command() {
    ssh -o ControlMaster=auto -o ControlPath="$CONTROL_PATH" -o ControlPersist=600 "$@"
}

# Function to start the SSH control master
start_control_master() {
    if ssh -S "$CONTROL_PATH" -O check o2jump 2>/dev/null; then
        echo "ControlMaster connection to o2jump already exists."
    else
        echo "Starting ControlMaster connection to o2jump."
        ssh -M -N -f -o ControlPath="$CONTROL_PATH" o2jump
    fi
}

# Function to connect and set up the environment
connect() {
    # Create necessary directories
    mkdir -p "$HOME/.ssh/controlmasters"
    mkdir -p "$SSH_CONFIG_DIR"

    # Start the SSH control master
    start_control_master

    # Verify the SBATCH script exists
    if ! ssh_command o2jump "test -f $SBATCH_SCRIPT_PATH"; then
        echo "Error: SBATCH script not found at $SBATCH_SCRIPT_PATH"
        exit 1
    fi

    # Submit the SBATCH script and capture the job ID
    job_submission=$(ssh_command o2jump "sbatch $SBATCH_SCRIPT_PATH")
    if [[ $? -ne 0 ]]; then
        echo "Error submitting job: $job_submission"
        exit 1
    fi

    job_id=$(echo "$job_submission" | awk '{print $4}')
    echo "Submitted job with ID: $job_id"

    # Wait for the job to start and get the compute node name
    echo "Waiting for the job to start..."
    while true; do
        job_info=$(ssh_command o2jump "squeue -j $job_id -h -o '%T %N'")
        job_state=$(echo "$job_info" | awk '{print $1}')
        node_name=$(echo "$job_info" | awk '{print $2}')
        if [[ "$job_state" == "RUNNING" && "$node_name" != "(None)" && "$node_name" != "n/a" && -n "$node_name" ]]; then
            echo "Job is running on node: $node_name"
            break
        fi
        sleep 5
    done

    # Update the SSH config for o2job
    local ssh_config_file="$SSH_CONFIG_DIR/o2job.conf"
    cat > "$ssh_config_file" << EOF
Host o2job
    HostName $node_name
    User adk9
    ProxyJump o2jump
    ForwardAgent yes
EOF

    echo "SSH config updated for o2job pointing to $node_name."

    # Verify VS Code is installed
    if ! command -v code &> /dev/null; then
        echo "Error: VS Code command 'code' not found."
        exit 1
    fi

    # Open VS Code connected to the compute node
    code --folder-uri "vscode-remote://ssh-remote+o2job$REMOTE_WORK_DIR"

    # Optional: Clean up the SSH config after use
    # Uncomment the following line if you want to remove the config after closing VS Code
    # rm "$ssh_config_file"
}

# Execute the connect function
connect
