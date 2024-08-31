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

### slurm job scheduling

How to check on the performance of a completed job:
`https://harvardmed.atlassian.net/wiki/spaces/O2/pages/1601699912/Get+information+about+current+and+past+jobs#O2_jobs_report`

```bash
O2_jobs_report -j <JOBID>
```

## Best practice basic UNIX

### File transfer

For rsync:

```bash
rsync -avh --progress source/ destination/
```

Using `lftp`

```bash
❯ which lftp
/opt/homebrew/bin/lftp
❯ lftp --version
LFTP | Version 4.9.2 | Copyright (c) 1996-2020 Alexander V. Lukyanov

LFTP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LFTP.  If not, see <http://www.gnu.org/licenses/>.

Send bug reports and questions to the mailing list <lftp@uniyar.ac.ru>.

Libraries used: idn2 2.3.7, libiconv 1.11, Readline 8.2, zlib 1.2.12
❯ lftp --help
Usage: lftp [OPTS] <site>
`lftp' is the first command executed by lftp after rc files
 -f <file>           execute commands from the file and exit
 -c <cmd>            execute the commands and exit
 --norc              don't execute rc files from the home directory
 --help              print this help and exit
 --version           print lftp version and exit
Other options are the same as in `open' command:
 -e <cmd>            execute the command just after selecting
 -u <user>[,<pass>]  use the user/password for authentication
 -p <port>           use the port for connection
 -s <slot>           assign the connection to this slot
 -d                  switch on debugging mode
 <site>              host name, URL or bookmark name
❯ lftp -u adk9,remote_password sftp://transfer.rc.hms.harvard.edu
lftp adk9@transfer.rc.hms.harvard.edu:~> 
lftp adk9@transfer.rc.hms.harvard.edu:~> pwd
sftp://adk9:remote_password@transfer.rc.hms.harvard.edu
lftp adk9@transfer.rc.hms.harvard.edu:~> lcd
lcd ok, local cwd=/Users/adk
lftp adk9@transfer.rc.hms.harvard.edu:~> cd ~
cd ok, cwd=/home/adk9   
lftp adk9@transfer.rc.hms.harvard.edu:~> lcd ~/Downloads/
lcd ok, local cwd=/Users/adk/Downloads
lftp adk9@transfer.rc.hms.harvard.edu:~> lls
Unknown command `lls'.
lftp adk9@transfer.rc.hms.harvard.edu:~> cd gh_repos/yan-mgx/data/
lftp adk9@transfer.rc.hms.harvard.edu:~/gh_repos/yan-mgx/data> mput sra_PRJEB49206.csv
515345 bytes transferred                                  
lftp adk9@transfer.rc.hms.harvard.edu:~/gh_repos/yan-mgx/data> 

```
