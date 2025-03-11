#!/bin/bash

# Create an empty array to store the unseal keys
UNSEAL_KEYS=()

# Get the unseal keys from the user
for ((i = 1; i <= 3; i++)); do
  echo "Enter unseal key $i:"
  read -s key
  UNSEAL_KEYS+=("$key")
done

# Define the vault pods
VAULT_PODS=("vault-0" "vault-1" "vault-2")

# Loop through each vault pod
for POD in "${VAULT_PODS[@]}"; do
  for KEY in "${UNSEAL_KEYS[@]}"; do
    # Execute the unseal command in the vault pod
    kubectl exec -it "$POD" --namespace=vault -- sh -c "vault operator unseal $KEY"
  done
done
