#!/usr/bin/env bash
# SSH Tunnel Port Forwarding Script

# Configuration Variables (Modify these to match your specific setup)
SSH_HOST=${SSH_HOST:-"user@example.com"} # Remote SSH server
LOCAL_PORT=${LOCAL_PORT:-8080}           # Local port to bind
REMOTE_PORT=${REMOTE_PORT:-80}           # Remote port to forward to
TUNNEL_PID_FILE="/tmp/ssh_tunnel.pid"

# Function to start SSH tunnel
start_tunnel() {
  # Check if tunnel is already running
  if [ -f "$TUNNEL_PID_FILE" ] && kill -0 "$(cat "$TUNNEL_PID_FILE")" 2>/dev/null; then
    echo "SSH tunnel is already running."
    return 1
  fi

  # Start SSH tunnel in background
  ssh -N -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} ${SSH_HOST} &
  SSH_PID=$!

  # Wait a moment to ensure tunnel is established
  sleep 2

  # Check if SSH process is running
  if kill -0 $SSH_PID 2>/dev/null; then
    echo $SSH_PID >"$TUNNEL_PID_FILE"
    echo "SSH tunnel started. Local port ${LOCAL_PORT} forwarded to ${REMOTE_PORT} on ${SSH_HOST}"
  else
    echo "Failed to establish SSH tunnel."
    return 1
  fi
}

# Function to stop SSH tunnel
stop_tunnel() {
  if [ ! -f "$TUNNEL_PID_FILE" ]; then
    echo "No SSH tunnel found running."
    return 1
  fi

  # Read PID from file
  TUNNEL_PID=$(cat "$TUNNEL_PID_FILE")

  # Attempt to kill the SSH process
  if kill "$TUNNEL_PID" 2>/dev/null; then
    rm "$TUNNEL_PID_FILE"
    echo "SSH tunnel stopped."
  else
    echo "Failed to stop SSH tunnel. PID ${TUNNEL_PID} not found."
  fi
}

# Main script logic
case "$1" in
on)
  start_tunnel
  ;;
off)
  stop_tunnel
  ;;
*)
  echo "Usage: $0 {on|off}"
  exit 1
  ;;
esac

exit 0
