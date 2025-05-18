#!/bin/bash

# All-in-One Bash Script for Installing Wallet and Wi-Fi Tools on Parrot OS
# Run this script with sudo privileges: sudo ./install_tools.sh

# Update and Upgrade the System
apt update && apt upgrade -y && apt dist-upgrade -y

# Install Basic Utilities and Dependencies
apt install -y curl wget git build-essential python3 python3-pip libssl-dev libffi-dev net-tools

# Install Cryptocurrency Wallet Tools
# Bitcoin Core (Full Node Wallet)
wget https://bitcoin.org/bin/bitcoin-core-25.0/bitcoin-25.0-x86_64-linux-gnu.tar.gz -O bitcoin.tar.gz
tar -xzf bitcoin.tar.gz
mv bitcoin-25.0/bin/* /usr/local/bin/
rm -rf bitcoin-25.0 bitcoin.tar.gz
mkdir ~/.bitcoin
echo "Bitcoin Core installed. Run 'bitcoind' to start the daemon or 'bitcoin-qt' for GUI."

# Electrum (Lightweight Bitcoin Wallet)
apt install -y electrum

# Ethereum Wallet (Geth - Go Ethereum Client)
apt install -y software-properties-common
add-apt-repository -y ppa:ethereum/ethereum
apt update
apt install -y geth
echo "Ethereum Geth installed. Run 'geth' to start syncing the blockchain."

# Monero Wallet (CLI)
wget https://downloads.getmonero.org/cli/monero-linux-x64-v0.18.3.1.tar.bz2 -O monero.tar.bz2
tar -xjf monero.tar.bz2
mv monero-x86_64-linux-gnu-v0.18.3.1/* /usr/local/bin/
rm -rf monero-x86_64-linux-gnu-v0.18.3.1 monero.tar.bz2
echo "Monero CLI Wallet installed. Run 'monero-wallet-cli' to start."

# Install Wi-Fi Auditing and Hacking Tools
# Aircrack-ng (Wi-Fi cracking suite)
apt install -y aircrack-ng

# Wireshark (Network protocol analyzer)
apt install -y wireshark
usermod -aG wireshark $USER

# Kismet (Wireless network detector and sniffer)
apt install -y kismet

# Reaver (WPS attack tool)
apt install -y reaver

# Fern Wi-Fi Cracker (GUI for Wi-Fi cracking)
apt install -y fern-wifi-cracker

# Bettercap (MITM and network attack framework)
apt install -y bettercap

# Install Additional Networking Tools
apt install -y nmap tcpdump Ettercap-graphical macchanger

# Install Python Tools for Automation and Scripting
pip3 install scapy requests beautifulsoup4

# Install Hashcat for Password Cracking (Useful for Wi-Fi and Wallet Recovery)
apt install -y hashcat

# Install Additional Security Tools for Wallet Protection and Recovery
apt install -y keepassxc veracrypt

# Configure Wi-Fi Tools Permissions and Setup
# Ensure user can capture packets without issues
chmod +x /usr/bin/dumpcap

# Final Message
echo "Installation complete!"
echo "Cryptocurrency Wallets Installed: Bitcoin Core, Electrum, Geth (Ethereum), Monero CLI"
echo "Wi-Fi and Network Tools Installed: Aircrack-ng, Wireshark, Kismet, Reaver, Fern Wi-Fi Cracker, Bettercap, Nmap, Tcpdump, Ettercap, MACchanger"
echo "Password and Security Tools: Hashcat, KeePassXC, VeraCrypt"
echo "Python libraries for scripting installed: Scapy, Requests, BeautifulSoup4"
echo "You may need to restart your system or log out for some changes (like Wireshark group permissions) to take effect."
echo "Ensure your Wi-Fi adapter supports monitor mode for tools like Aircrack-ng. Check with 'iwconfig'."

