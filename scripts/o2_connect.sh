#!/bin/bash

# Path to store the SSH control master socket
CONTROL_PATH="~/.ssh/controlmasters/%r@%h:%p"

# Function to execute an SSH command with the control master socket
ssh_command() {
    ssh -o ControlPath=$CONTROL_PATH "$@"
}

# Function to start the SSH control master
start_control_master() {
    # Check if a control master connection already exists
    if ssh -S $CONTROL_PATH -O check o2jump 2>/dev/null; then
        echo "ControlMaster connection already exists."
    else
        echo "Starting a new ControlMaster connection."
        # Start a new control master connection in the background
        ssh -M -N -f -o ControlPath=$CONTROL_PATH o2jump
    fi
}

# Function to connect to the remote server and start VS Code
connect() {
    # Path to the SBATCH script for starting VS Code
    sbatch_script_path="/home/adk9/gh_repos/ssh-info/scripts/start_vs_code_job.sh"

    # Create the directory to store the control master socket
    mkdir -p ~/.ssh/controlmasters

    # Start the SSH control master
    start_control_master

    # Check if the SBATCH script exists on the remote server
    if ! ssh_command o2jump "test -f $sbatch_script_path"; then
        echo "Error: SBATCH script not found at $sbatch_script_path"
        exit 1
    fi

    # Submit the SBATCH script as a job and get the job ID
    job_id=$(ssh_command o2jump "sbatch $sbatch_script_path" | awk '{print $4}')

    echo "Submitted job with ID: $job_id"

    # Wait for the job to start running on a compute node
    while true; do
        # Get the name of the compute node running the job
        node_name=$(ssh_command o2jump "squeue -j $job_id -h -o '%N' | grep -vE '^(\s|N/A|\(None\))$'")
        if [[ -n $node_name ]]; then
            echo "Job running on node: $node_name"
            break
        fi
        echo "Waiting for job to start..."
        sleep 5
    done

    # Backup the SSH config file
    cp ~/.ssh/config ~/.ssh/config.bak

    # Remove any existing SSH config entries for the 'o2job' host
    sed -i.bak "/Host o2job/,+4d" ~/.ssh/config

    # Add a new SSH config entry for the 'o2job' host with the compute node name
    ssh_config_line="Host o2job\n  HostName $node_name\n  User adk9\n  ProxyJump o2jump\n  ForwardAgent yes\n  ControlMaster auto\n  ControlPath $CONTROL_PATH\n  ControlPersist 10m"
    echo -e "$ssh_config_line" >> ~/.ssh/config

    echo "Updated SSH config with node name: $node_name"

    # Check if the 'code' command is available
    if ! command -v code &> /dev/null; then
        echo "VS Code command 'code' not found. Please install 'code' command."
        exit 1
    fi

    # Open VS Code with the SSH remote URI for the 'o2job' host
    code --folder-uri "vscode-remote://ssh-remote+o2job/home/adk9/gh_repos"
}

# Always run the connect function
connect
