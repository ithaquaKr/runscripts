#!/bin/bash
# BUG: Cannot use
# Check if the .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found."
  exit 1
fi

# Create an empty JSON object
json="{"

# Read each line in the .env file
while IFS= read -r line; do
  # Ignore comments and empty lines
  if [[ "$line" =~ ^\ *# || -z "$line" ]]; then
    continue
  fi

  # Extract key and value
  key=$(echo "$line" | cut -d '=' -f1)
  value=$(echo "$line" | cut -d '=' -f2-)

  # Trim leading and trailing whitespaces from the value
  value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Add key-value pair to JSON object
  json="$json\"$key\":\"$value\","
done <.env

# Remove the trailing comma and close the JSON object
json="${json%,}}"
echo "$json" >env.json

echo "Conversion completed. JSON structure saved to env.json."
