#!/bin/bash

# Configuration
ALLOWED_START_TIME="07:10"
ALLOWED_END_TIME="22:50"
BLOCKED_SITES=("instagram.com" "www.instagram.com" "youtube.com" "www.youtube.com")
HOSTS_FILE="/etc/hosts"
IPTABLES_CHAIN="SOCIAL_BLOCK"

# Check for required commands
check_dependencies() {
    if ! command -v host >/dev/null 2>&1; then
        echo "Installing 'host' command (bind-utils/dnsutils)..."
        if command -v pacman >/dev/null 2>&1; then
            pacman -S bind --noconfirm
        else
            echo "Please install bind-utils or dnsutils for your distribution"
            exit 1
        fi
    fi
}

# Function to check if current time is within blocked period
check_time() {
    current_time=$(date +%H:%M)
    
    if [[ "$current_time" > "$ALLOWED_START_TIME" && "$current_time" < "$ALLOWED_END_TIME" ]]; then
        echo "Current time: $current_time - Access BLOCKED (work hours)"
        return 0  # Return 0 to block during work hours
    else
        echo "Current time: $current_time - Access ALLOWED (leisure hours)"
        return 1
    fi
}

# Function to set up iptables rules
setup_iptables() {
    # Create new chain if it doesn't exist
    iptables -N $IPTABLES_CHAIN 2>/dev/null || true
    
    # Flush existing rules in our chain
    iptables -F $IPTABLES_CHAIN
    
    # Add rules for each blocked site
    for site in "${BLOCKED_SITES[@]}"; do
        # Resolve IP addresses
        ips=$(host $site | grep "has address" | awk '{print $4}')
        for ip in $ips; do
            iptables -A $IPTABLES_CHAIN -d $ip -j REJECT
        done
    done
    
    # Link our chain to OUTPUT chain if not already done
    iptables -C OUTPUT -j $IPTABLES_CHAIN 2>/dev/null || \
    iptables -A OUTPUT -j $IPTABLES_CHAIN
}

# Function to modify hosts file
modify_hosts() {
    # Remove immutable attribute if set
    chattr -i $HOSTS_FILE 2>/dev/null || true
    
    # Back up hosts file if backup doesn't exist
    if [ ! -f "${HOSTS_FILE}.backup" ]; then
        cp $HOSTS_FILE "${HOSTS_FILE}.backup"
    fi
    
    # Remove any existing blocks
    sed -i '/## SOCIAL_MEDIA_BLOCK/,/## END_SOCIAL_MEDIA_BLOCK/d' $HOSTS_FILE
    
    # Add new blocks
    echo "## SOCIAL_MEDIA_BLOCK" >> $HOSTS_FILE
    for site in "${BLOCKED_SITES[@]}"; do
        echo "0.0.0.0 $site" >> $HOSTS_FILE
    done
    echo "## END_SOCIAL_MEDIA_BLOCK" >> $HOSTS_FILE
    
    # Set immutable attribute back
    chattr +i $HOSTS_FILE 2>/dev/null || true
}

# Function to clear blocks
clear_blocks() {
    # Remove immutable attribute
    chattr -i $HOSTS_FILE 2>/dev/null || true
    
    # Clear hosts file entries
    sed -i '/## SOCIAL_MEDIA_BLOCK/,/## END_SOCIAL_MEDIA_BLOCK/d' $HOSTS_FILE
    
    # Clear iptables rules
    iptables -F $IPTABLES_CHAIN
    
    # Set immutable attribute back
    chattr +i $HOSTS_FILE 2>/dev/null || true
}

# Set up systemd service
setup_systemd_service() {
    cat > "/etc/systemd/system/social-block.service" << EOF
[Unit]
Description=Social Media Blocking Service
After=network.target

[Service]
ExecStart=$(readlink -f "$0")
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable social-block
    systemctl start social-block
}

# Main execution
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Check dependencies
check_dependencies

# Initial setup
setup_systemd_service

# Monitor and enforce continuously
while true; do
    if check_time; then
        # During work hours (block)
        setup_iptables
        modify_hosts
    else
        # Outside work hours (allow)
        clear_blocks
    fi
    sleep 60
done
