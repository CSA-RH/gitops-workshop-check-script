#!/bin/bash

# Max number of users (first argument or default to 20)
MAX_USERS="${1:-20}"

# Base domain (second argument or default, WITHOUT /bubble)
RAW_DOMAIN="${2:-apps.cluster-p7sr9.p7sr9.sandbox2601.opentlc.com}"

# Bubble base path (used for first 3 steps)
BUBBLE_DOMAIN="${RAW_DOMAIN}/bubble"

# Step definitions: URL | match type | column label
STEPS=(
  "http://bgd-user{}-bgd.${BUBBLE_DOMAIN}|blue|2.Basics"
  "http://bgd-user{}-bgdk.${BUBBLE_DOMAIN}|yellow|3.Kustomize"
  "http://bgd-helm-user{}-bgdh.${BUBBLE_DOMAIN}|merged|4.Helm"
  "http://todo-user{}-todo.${RAW_DOMAIN}/todo.html|sync|5.SyncWaves"
)

# Print table header
printf "%-6s | %-10s | %-13s | %-7s | %-11s\n" "User" "2.Basics" "3.Kustomize" "4.Helm" "5.SyncWaves"
echo "--------------------------------------------------------------------------"

# Function to check step
check_step() {
  local url=$1
  local match=$2
  local user=$3

  full_url=$(echo "$url" | sed "s/{}/$user/g")
  content=$(curl -s "$full_url")

  case "$match" in
    blue)
      echo "$content" | grep -q "blue" && echo "✅" || echo "❌"
      ;;
    yellow)
      echo "$content" | grep -q "yellow" && echo "✅" || echo "❌"
      ;;
    merged)
      if echo "$content" | grep -q "purple"; then
        echo "✅"
      elif echo "$content" | grep -q "green"; then
        echo "🟢"
      elif echo "$content" | grep -q "yellow"; then
        echo "🟡"
      else
        echo "❌"
      fi
      ;;
    sync)
      echo "$content" | grep -q "What needs to be done?" && echo "✅" || echo "❌"
      ;;
  esac
}

# Loop through users
for user in $(seq 1 "$MAX_USERS"); do
  results=()
  for step in "${STEPS[@]}"; do
    url="${step%%|*}"
    tmp="${step#*|}"
    match="${tmp%%|*}"
    result=$(check_step "$url" "$match" "$user")
    results+=("$result")
  done
  printf "%-6s | %-10s | %-13s | %-7s | %-11s\n" "$user" "${results[@]}"
done
