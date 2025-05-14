#!/bin/bash

# Max number of users (first argument or default to 20)
MAX_USERS="${1:-20}" ##REPLACE

# Base domain (second argument or default)
RAW_DOMAIN="${2:-apps.cluster-abc123.abc123.sandbox9999.opentlc.com}" ##REPLACE

# Full domain with /bubble suffix
BASE_DOMAIN="${RAW_DOMAIN}/bubble"

# Step definitions: URL | match type | column label
STEPS=(
  "http://bgd-user{}-bgd.${BASE_DOMAIN}|blue|2.Basics"
  "http://bgd-user{}-bgdk.${BASE_DOMAIN}|yellow|3.Kustomize"
  "http://bgd-helm-user{}-bgdh.${BASE_DOMAIN}|merged|4.Helm"
)

# Print table header
printf "%-6s | %-10s | %-13s | %-7s\n" "User" "2.Basics" "3.Kustomize" "4.Helm"
echo "----------------------------------------------------------"

# Function to check step
check_step() {
  local url=$1
  local match=$2
  local user=$3

  # Replace {} with user number
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
  esac
}

# Loop through each user
for user in $(seq 1 "$MAX_USERS"); do
  results=()
  for step in "${STEPS[@]}"; do
    url="${step%%|*}"
    tmp="${step#*|}"
    match="${tmp%%|*}"
    result=$(check_step "$url" "$match" "$user")
    results+=("$result")
  done
  # Print the row
  printf "%-6s | %-10s | %-13s | %-7s\n" "$user" "${results[@]}"
done
