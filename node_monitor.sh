#!/bin/bash
CONFIG_FILE="t3rn_node_config.json"
LOG_FILE="node.log"
ERROR_LIMIT=10
RESTART_DELAY=60

# Function to rotate L1RN RPC endpoints
rotate_l1rn_endpoints() {
    echo "Rotating L1RN RPC endpoints..."
    
    # Get current endpoints from config
    current_l1rn=$(jq -r '.parameters.rpc_endpoints.L1RN' "$CONFIG_FILE")
    
    # Split into array and rotate
    IFS=',' read -ra endpoints <<< "$current_l1rn"
    if [ ${#endpoints[@]} -gt 1 ]; then
        # Rotate positions (move first element to end)
        rotated_endpoints="${endpoints[*]:1},${endpoints[0]}"
    else
        rotated_endpoints="$current_l1rn"
    fi
    
    # Update config file
    jq --arg new_l1rn "$rotated_endpoints" \
       '.parameters.rpc_endpoints.L1RN = $new_l1rn' \
       "$CONFIG_FILE" > tmp.json && mv tmp.json "$CONFIG_FILE"
    
    echo "New L1RN order: $rotated_endpoints"
}

# Function to check errors
check_errors() {
    tail -n 100 "$LOG_FILE" | grep -c '❌ RPC error at getBalance'
}

# Function to restart node
restart_node() {
    echo "Restarting node..."
    pkill -f executor
    sleep 2
    
    # Rotate L1RN endpoints before restart
    rotate_l1rn_endpoints
    
    # Check for new version
    CURRENT_VERSION=$(jq -r .version "$CONFIG_FILE")
    LATEST_VERSION=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | jq -r .tag_name)
    
    if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
        echo "New version detected ($LATEST_VERSION). Updating..."
        ARCHIVE_NAME=$(jq -r .archive_name "$CONFIG_FILE")
        DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_VERSION/executor-linux-$LATEST_VERSION.tar.gz"
        
        wget "$DOWNLOAD_URL" -O "$ARCHIVE_NAME"
        tar -xvzf "$ARCHIVE_NAME"
    fi
    
    # Start node with updated configuration
    cd t3rn/executor/executor/bin || exit 1
    export $(jq -r '.parameters | to_entries[] | "\(.key)=\(.value)"' ../../$CONFIG_FILE | xargs)
    nohup ./executor > "$LOG_FILE" 2>&1 &
}

# Main monitoring loop
while true; do
    ERROR_COUNT=$(check_errors)
    
    if [[ $ERROR_COUNT -ge $ERROR_LIMIT ]]; then
        echo "Critical error threshold reached ($ERROR_COUNT errors). Initiating restart..."
        restart_node
        echo "Node restarted. Waiting $RESTART_DELAY seconds before next check..."
        sleep $RESTART_DELAY
    fi
    
    sleep 30
done
