# SSH to O2 and Beyond

## getting started on o2

HMS IT RC O2 is a comprehensive resource:
`https://harvardmed.atlassian.net/wiki/spaces/O2/`

The new O2Portal runs Open OnDemand (OOD). Provides info on Quota Utilization, slurm job control, apps, etc.
`https://o2portal.rc.hms.harvard.edu/`

### basic login

```bash
#Login to O2
ssh adk9@o2.hms.harvard.edu
#pw: &r?@fKTH8L7@

#Log in to transfer files
ssh adk9@transfer.rc.hms.harvard.edu
# There is a directory only accessible via `transfer`:
cd /n/standby/joslin/kostic/
# serves as a backup directory (long-term storage)
```

### local VS Code Remote-SSH into O2

I have this janky script, but it works. there is meant to be a `terminate` function in addtion to `connect`, but never got it to work.
Using my MBP M3 running terminal:

```bash

bash ~/ssh-info/o2_connect.sh
```

This script will send SEVERAL MFA prompts to phone. It will launch VS Code and SSH into O2. It launches the following script on O2:
`/home/adk9/VScode_SSH-remote/start_vs_code_job.sh`

```bash
#!/bin/bash

#SBATCH -p priority
#SBATCH -c 1
#SBATCH --mem=4G
#SBATCH -t 24:00:00
#SBATCH --job-name="vscodetunnel"

# Load necessary modules if needed
~/.bashrc

# Sleep for the duration of the job
sleep 24h  # Adjust as needed
```

When finished working, this is the shutdown procedure:

- w/i VS Code: close any open terminals
- w/i VS Code: Hit the blue `SSH: o2job` button at very bottom left, then from drop down choose `Close Remote Connection`
- finally, in a separate terminal connected to o2,

I also made a video!
See `vscode_ssh_o2.mp4`
