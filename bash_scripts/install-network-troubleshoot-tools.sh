#!/bin/bash

# Network Troubleshooting Tools Installer for Ubuntu 24.04
# This script installs comprehensive network diagnostic and troubleshooting tools
# I'll create a comprehensive bash script to install network troubleshooting tools on Ubuntu 24.04.This comprehensive bash script will install all the essential network troubleshooting tools on Ubuntu 24.04. Here's what it includes:
## Features:
# **Basic Network Tools:**
# - `net-tools` (ifconfig, netstat, arp, route)
# - `iproute2` (ip, ss, tc)
# - `ping`, `traceroute`, `dig`, `nslookup`
# - `wget`, `curl`, `netcat`, `telnet`
#
# **Advanced Analysis Tools:**
# - `wireshark` (GUI packet analyzer)
# - `tcpdump` (command-line packet capture)
# - `nmap` (network scanner)
# - `iftop`, `nethogs` (bandwidth monitoring)
# - `iperf3` (throughput testing)
#
# **Security & Monitoring:**
# - `ngrep`, `tshark`
# - `masscan`, `hping3`
# - `arping`, `fping`
# - `lsof` (network connections)
#
# **Wireless Tools:**
# - `wireless-tools` (iwconfig, iwlist)
# - `aircrack-ng` (wireless security)
# - `wavemon` (wireless monitoring)
#
# **Useful Utilities:**
# - `speedtest-cli`
# - Custom aliases and functions for quick troubleshooting
#
# ## Usage:
#
# 1. Save the script as `install_network_tools.sh`
# 2. Make it executable: `chmod +x install_network_tools.sh`
# 3. Run it: `./install_network_tools.sh`
#
# The script includes safety checks, colored output, error handling, and will create useful aliases for common network troubleshooting tasks. It also handles permissions properly for tools like Wireshark that require special access for packet capture.

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
  if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
  fi
}

# Function to check if user has sudo privileges
check_sudo() {
  if ! sudo -n true 2>/dev/null; then
    print_error "This script requires sudo privileges. Please run with a user that has sudo access."
    exit 1
  fi
}

# Function to update package lists
update_packages() {
  print_status "Updating package lists..."
  sudo apt update
  print_success "Package lists updated"
}

# Function to install basic network tools
install_basic_tools() {
  print_status "Installing basic network tools..."

  local basic_tools=(
    "net-tools"         # ifconfig, netstat, arp, route
    "iproute2"          # ip, ss, tc
    "iputils-ping"      # ping
    "iputils-tracepath" # tracepath
    "traceroute"        # traceroute
    "dnsutils"          # dig, nslookup, host
    "wget"              # wget
    "curl"              # curl
    "telnet"            # telnet
    "netcat-openbsd"    # nc (netcat)
    "whois"             # whois
    "mtr-tiny"          # mtr (network diagnostic tool)
  )

  for tool in "${basic_tools[@]}"; do
    print_status "Installing $tool..."
    sudo apt install -y "$tool"
  done

  print_success "Basic network tools installed"
}

# Function to install advanced network analysis tools
install_advanced_tools() {
  print_status "Installing advanced network analysis tools..."

  local advanced_tools=(
    "wireshark"    # Network protocol analyzer
    "tcpdump"      # Command-line packet analyzer
    "nmap"         # Network mapper and port scanner
    "iftop"        # Display bandwidth usage on interface
    "nethogs"      # Net top tool grouping bandwidth per process
    "iotop"        # I/O monitoring
    "htop"         # Process viewer
    "vnstat"       # Network traffic monitor
    "bandwidthd"   # Bandwidth monitoring daemon
    "ntopng"       # Network traffic probe
    "iperf3"       # Network throughput testing
    "ethtool"      # Ethernet device configuration
    "bridge-utils" # Bridge configuration utilities
    "vlan"         # VLAN configuration utilities
  )

  for tool in "${advanced_tools[@]}"; do
    print_status "Installing $tool..."
    sudo apt install -y "$tool"
  done

  print_success "Advanced network tools installed"
}

# Function to install security and monitoring tools
install_security_tools() {
  print_status "Installing network security and monitoring tools..."

  local security_tools=(
    "ngrep"          # Network grep
    "tshark"         # Terminal Wireshark
    "masscan"        # Fast port scanner
    "hping3"         # Network tool for crafting packets
    "arping"         # ARP ping
    "fping"          # Fast ping for multiple hosts
    "socat"          # Socket cat
    "stunnel4"       # SSL tunnel
    "openssh-client" # SSH client
    "rsync"          # File synchronization
    "lsof"           # List open files and network connections
  )

  for tool in "${security_tools[@]}"; do
    print_status "Installing $tool..."
    sudo apt install -y "$tool"
  done

  print_success "Security and monitoring tools installed"
}

# Function to install wireless tools
install_wireless_tools() {
  print_status "Installing wireless network tools..."

  local wireless_tools=(
    "wireless-tools" # iwconfig, iwlist
    "wpasupplicant"  # WPA/WPA2 supplicant
    "iw"             # nl80211 based CLI configuration utility
    "wavemon"        # Wireless network monitoring
    "aircrack-ng"    # Wireless security auditing
  )

  for tool in "${wireless_tools[@]}"; do
    print_status "Installing $tool..."
    sudo apt install -y "$tool"
  done

  print_success "Wireless network tools installed"
}

# Function to install additional useful utilities
install_utilities() {
  print_status "Installing additional network utilities..."

  local utilities=(
    "speedtest-cli"        # Internet speed test
    "lynx"                 # Text-based web browser
    "links"                # Text-based web browser
    "bind9-utils"          # DNS utilities
    "mailutils"            # Mail utilities
    "postfix"              # Mail transfer agent (for testing)
    "snmp"                 # SNMP tools
    "snmp-mibs-downloader" # SNMP MIBs
    "rpcbind"              # RPC port mapper
    "nfs-common"           # NFS client utilities
    "cifs-utils"           # CIFS/SMB utilities
  )

  for tool in "${utilities[@]}"; do
    print_status "Installing $tool..."
    if [[ "$tool" == "postfix" ]]; then
      # Install postfix non-interactively
      sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix
    else
      sudo apt install -y "$tool"
    fi
  done

  print_success "Additional utilities installed"
}

# Function to configure user permissions for network tools
configure_permissions() {
  print_status "Configuring permissions for network tools..."

  # Add user to wireshark group for packet capture
  if getent group wireshark >/dev/null 2>&1; then
    sudo usermod -a -G wireshark $USER
    print_success "Added $USER to wireshark group"
  fi

  # Configure dumpcap permissions
  if command -v dumpcap >/dev/null 2>&1; then
    sudo dpkg-reconfigure wireshark-common
  fi

  print_success "Permissions configured"
}

# Function to create useful aliases and functions
create_aliases() {
  print_status "Creating useful network aliases..."

  # Create aliases file
  cat <<'EOF' >/tmp/network_aliases.sh
# Network troubleshooting aliases
alias ports='netstat -tulanp'
alias listening='ss -tulpn'
alias established='ss -tupn'
alias netinfo='ip addr show'
alias routes='ip route show'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I'
alias dnstest='dig +short google.com'
alias speedtest='speedtest-cli'
alias netwatch='watch -n 1 "ss -tupln"'
alias bandwidth='iftop -n'
alias connections='netstat -an | grep ESTABLISHED | wc -l'

# Network functions
pingtest() {
    if [ $# -eq 0 ]; then
        echo "Usage: pingtest <hostname>"
        return 1
    fi
    ping -c 4 $1
}

portcheck() {
    if [ $# -ne 2 ]; then
        echo "Usage: portcheck <hostname> <port>"
        return 1
    fi
    nc -zv $1 $2
}

tracenet() {
    if [ $# -eq 0 ]; then
        echo "Usage: tracenet <hostname>"
        return 1
    fi
    traceroute $1
    echo "---"
    mtr -r -c 4 $1
}

# DNS lookup function
dnsinfo() {
    if [ $# -eq 0 ]; then
        echo "Usage: dnsinfo <hostname>"
        return 1
    fi
    echo "=== A Records ==="
    dig +short $1 A
    echo "=== AAAA Records ==="
    dig +short $1 AAAA
    echo "=== MX Records ==="
    dig +short $1 MX
    echo "=== NS Records ==="
    dig +short $1 NS
    echo "=== TXT Records ==="
    dig +short $1 TXT
}
EOF

  # Uncomment it if you use bash
  # Add to user's bashrc
  # if ! grep -q "network_aliases.sh" ~/.bashrc; then
  #   echo "" >>~/.bashrc
  #   echo "# Network troubleshooting aliases and functions" >>~/.bashrc
  #   echo "source ~/.network_aliases.sh" >>~/.bashrc
  # fi

  # Add to user's zshrc
  if ! grep -q "network_aliases.sh" ~/.zshrc; then
    echo "" >>~/.bashrc
    echo "# Network troubleshooting aliases and functions" >>~/.zshrc
    echo "source ~/.network_aliases.sh" >>~/.zshrc
  fi

  # Move aliases to user's home directory
  mv /tmp/network_aliases.sh ~/.network_aliases.sh

  print_success "Network aliases and functions created"
}

# Function to display installed tools summary
display_summary() {
  print_success "Network troubleshooting tools installation completed!"
  echo ""
  echo -e "${BLUE}Installed categories:${NC}"
  echo "  • Basic tools: ping, traceroute, dig, netstat, ip, ss, etc."
  echo "  • Advanced analysis: wireshark, tcpdump, nmap, iftop, nethogs"
  echo "  • Security tools: ngrep, tshark, masscan, hping3"
  echo "  • Wireless tools: iwconfig, aircrack-ng, wavemon"
  echo "  • Utilities: speedtest-cli, iperf3, vnstat, etc."
  echo ""
  echo -e "${YELLOW}Important notes:${NC}"
  echo "  • Run 'source ~/.bashrc' or start a new terminal to use aliases"
  echo "  • You may need to log out/in for wireshark group permissions"
  echo "  • Use 'sudo wireshark' or configure dumpcap for packet capture"
  echo "  • Run 'sudo systemctl enable vnstat' to enable traffic monitoring"
  echo ""
  echo -e "${GREEN}Quick test commands:${NC}"
  echo "  • ping google.com"
  echo "  • nmap -sn 192.168.1.0/24"
  echo "  • speedtest-cli"
  echo "  • iftop (requires sudo)"
  echo "  • ss -tulpn"
}

# Main execution
main() {
  echo "========================================="
  echo "Network Troubleshooting Tools Installer"
  echo "         Ubuntu 24.04 LTS"
  echo "========================================="
  echo ""

  check_root
  check_sudo

  print_status "Starting installation process..."

  update_packages
  install_basic_tools
  install_advanced_tools
  install_security_tools
  install_wireless_tools
  install_utilities
  configure_permissions
  create_aliases

  echo ""
  display_summary
}

# Run main function
main "$@"
