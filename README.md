# AI DevOps Script Demo: VM Health Check

A Bash script, generated with the help of GitHub Copilot in VS Code, that checks
the health of an Ubuntu virtual machine. 

## What the script checks

| Metric | How it is measured |
|--------|--------------------|
| CPU utilization | `vmstat` (falls back to `/proc/stat`) |
| Memory utilization | `free` (used / total) |
| Disk utilization | `df` on the root `/` filesystem |

Each value is compared against a **60% threshold**. The script prints the status
`Healthy` or `Unhealthy` along with the three values.

## Requirements

- Ubuntu or any Linux VM (also works in WSL)
- Bash
- Standard tools: `vmstat`, `free`, `df`, `awk`

> This is a Linux script, so it will not run in Windows PowerShell.

## How I built it

1. Opened Visual Studio Code and clicked the Copilot icon.
2. Wrote a prompt asking for a VM health check script for Ubuntu.
3. Copilot generated the code.
4. Created a project folder `AI-Devops-Project` and a file `vm_health_check.sh`.
5. Pasted the generated code into the file.
6. Opened a terminal and ran the script.

## How to run

```bash
chmod +x vm_health_check.sh
./vm_health_check.sh
```

Or run it directly with Bash:

```bash
bash vm_health_check.sh
```

For a plain-English explanation of the result:

```bash
bash vm_health_check.sh (explaination)

The script marks the VM **healthy when all metrics are at or above 60%**.
```

## Output

```
VM Health Status: unHealthy
Target VM: Ubuntu
CPU Utilization: 95%
Memory Utilization: 5%
Disk Utilization: 1%
```

## Things I noticed

- The script marks the VM **healthy when all metrics are at or above 60%**.
  This follows the requirement given in the prompt. In real monitoring, high
  utilization usually signals a problem, so production checks normally flag a
  VM as unhealthy when usage goes **above** a threshold.
- Possible improvements:
  - Flip the logic so high usage triggers the warning
  - Make the threshold configurable through an argument
  - Check additional disks or mount points
  - Send an alert (for example, SNS or email) when the status is unhealthy
