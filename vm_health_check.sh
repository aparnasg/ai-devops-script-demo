#!/usr/bin/env bash

# VM health check for Ubuntu-based virtual machines.
# Health threshold: all resource metrics must be at least 60% utilized.
# If any metric is below 60%, the VM is considered unhealthy.

THRESHOLD=60
EXPLAIN=false

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [explain]"
  exit 1
fi

if [ "${1:-}" = "explain" ] || [ "${1:-}" = "--explain" ]; then
  EXPLAIN=true
fi

get_cpu_utilization() {
  if command -v vmstat >/dev/null 2>&1; then
    local idle
    idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
    if [ -n "$idle" ] && [ "$idle" != "0" ]; then
      echo $((100 - idle))
      return
    fi
  fi

  if [ -f /proc/stat ]; then
    local idle_before total_before idle_after total_after
    read -r _ _ _ idle_before _ < /proc/stat
    total_before=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8+$9+$10}' /proc/stat)
    sleep 1
    read -r _ _ _ idle_after _ < /proc/stat
    total_after=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8+$9+$10}' /proc/stat)

    local idle_delta total_delta
    idle_delta=$((idle_after - idle_before))
    total_delta=$((total_after - total_before))

    if [ "$total_delta" -gt 0 ]; then
      echo $((100 - (idle_delta * 100 / total_delta)))
      return
    fi
  fi

  echo 0
}

get_memory_utilization() {
  local used total
  used=$(free | awk '/^Mem:/ {print $3}')
  total=$(free | awk '/^Mem:/ {print $2}')

  if [ -n "$total" ] && [ "$total" -gt 0 ]; then
    echo $((used * 100 / total))
  else
    echo 0
  fi
}

get_disk_utilization() {
  local disk_usage
  disk_usage=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')

  if [ -n "$disk_usage" ]; then
    echo "$disk_usage"
  else
    echo 0
  fi
}

CPU_UTIL=$(get_cpu_utilization)
MEM_UTIL=$(get_memory_utilization)
DISK_UTIL=$(get_disk_utilization)

if [ "$CPU_UTIL" -ge "$THRESHOLD" ] && [ "$MEM_UTIL" -ge "$THRESHOLD" ] && [ "$DISK_UTIL" -ge "$THRESHOLD" ]; then
  STATUS="Healthy"
  EXPLANATION="All resource checks are at or above ${THRESHOLD}% utilization, so the Ubuntu VM is operating within the expected health threshold."
else
  STATUS="Unhealthy"
  EXPLANATION="One or more metrics are below ${THRESHOLD}% utilization, so the VM is below the expected health threshold."
fi

printf 'VM Health Status: %s\n' "$STATUS"
printf 'Target VM: Ubuntu\n'
printf 'CPU Utilization: %s%%\n' "$CPU_UTIL"
printf 'Memory Utilization: %s%%\n' "$MEM_UTIL"
printf 'Disk Utilization: %s%%\n' "$DISK_UTIL"

if [ "$EXPLAIN" = true ]; then
  echo
  echo "Explanation: $EXPLANATION"
  if [ "$STATUS" = "Healthy" ]; then
    echo "The VM is healthy because CPU, memory, and disk space are all at or above the 60% threshold."
  else
    echo "The VM is unhealthy because at least one resource is below the 60% threshold."
    if [ "$CPU_UTIL" -lt "$THRESHOLD" ]; then
      echo "- CPU has dropped below 60% utilization."
    fi
    if [ "$MEM_UTIL" -lt "$THRESHOLD" ]; then
      echo "- Memory has dropped below 60% utilization."
    fi
    if [ "$DISK_UTIL" -lt "$THRESHOLD" ]; then
      echo "- Disk space usage is below 60% utilization."
    fi
  fi
fi
