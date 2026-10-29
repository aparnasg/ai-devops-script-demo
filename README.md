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


## How to Run

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
bash vm_health_check.sh explain
```

## Output

```
VM Health Status: Unhealthy
Target VM: Ubuntu
CPU Utilization: 95%
Memory Utilization: 5%
Disk Utilization: 1%
<img width="975" height="284" alt="image" src="https://github.com/user-attachments/assets/02b85a03-00c2-4528-b350-b3e8ee2bf207" />


```
## Things I noticed
- In my run, the VM was reported **Unhealthy** even though memory (5%) and disk (1%)
  were almost empty. This confirms the logic is backwards: low usage should be healthy.
- The script marks the VM **healthy when all metrics are at or above 60%**.
  This follows the requirement given in the prompt. In real monitoring, high
  utilization usually signals a problem, so production checks normally flag a
  VM as unhealthy when usage goes **above** a threshold.

- Possible improvements:

## Things I noticed
• Flip the rule: the VM is Unhealthy when CPU, memory OR disk goes ABOVE 80%
• With that rule, my run would be flagged only for the 95% CPU, which is the real concern
• Next: implement it, make the threshold configurable, check more disks, and add AWS SNS alerts
