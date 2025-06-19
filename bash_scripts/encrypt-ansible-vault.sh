#!/usr/bin/env bash
# Script Name: encrypt-ansible-vault.sh
# Description: This script use to encrypt string secret using ansible-vault.
# Maintainer: Ithadev Ng <ithadev.nguyen@gmail.com>
# Last Updated: 2025-03-24
# Version: 0.1

# Prompt the user to enter the encrypted value
echo "Enter the encrypted value (end with Ctrl+D when done):"
ENCRYPTED_VALUE=$(cat | sed 's/^[[:space:]]*//')

# Prompt for the vault password securely
read -r -s -p "Enter the vault password: " VAULT_PASS
echo

# Decrypt the value using ansible-vault
DECRYPTED_VALUE=$(ansible-vault decrypt --vault-password-file <(echo "$VAULT_PASS") <<<"$ENCRYPTED_VALUE" 2>/dev/null)

# Check if decryption was successful
if [[ $? -eq 0 ]]; then
  echo "Decrypted value: $DECRYPTED_VALUE"
else
  echo "Error: Failed to decrypt. Check your vault password or encrypted value."
fi
