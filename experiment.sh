#!/bin/bash

# Step 0: Clean up previous installations
echo "Cleaning up previous installations..."
if [ -d "t3rn" ]; then
    echo "Deleting existing t3rn directory..."
    rm -rf t3rn
fi

if [ -d "executor" ]; then
    echo "Deleting existing executor directory..."
    rm -rf executor
fi

if ls executor-linux-*.tar.gz 1> /dev/null 2>&1; then
    echo "Deleting previously downloaded tar.gz files..."
    rm -f executor-linux-*.tar.gz
fi

# Step 1: Create and navigate to t3rn directory
echo "Creating and navigating to t3rn directory..."
mkdir -p t3rn
cd t3rn || { echo "Failed to create or navigate to t3rn directory. Exiting."; exit 1; }

# Step 2: Download the latest release
echo "Downloading the latest release..."
LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$LATEST_TAG" ]; then
    echo "Failed to fetch the latest release tag. Please check your internet connection and try again."
    exit 1
fi

DOWNLOAD_URL="https://github.com/t3rn/executor-release/releases/download/$LATEST_TAG/executor-linux-$LATEST_TAG.tar.gz"
wget "$DOWNLOAD_URL" -O "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to download the latest release. Please check the URL and try again."
    exit 1
fi
echo "Download complete."

# Step 3: Extract the archive
echo "Extracting the archive..."
tar -xzf "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to extract the archive. Please check the file and try again."
    exit 1
fi
echo "Extraction complete."

# Step 4: Navigate to the executor binary location
echo "Navigating to the executor binary location..."
mkdir -p executor/executor/bin
cd executor/executor/bin || { echo "Failed to navigate to executor binary location. Exiting."; exit 1; }

# Function to ask for user input
ask_for_input() {
    local prompt="$1"
    local input

    read -p "$prompt: " input
    echo "$input"
}

# Function to validate gas value
validate_gas_value() {
    local gas_value="$1"
    
    # Check if the input is an integer
    if [[ ! "$gas_value" =~ ^[0-9]+$ ]]; then
        echo "Error: Gas value must be an integer."
        return 1
    fi

    # Check if the gas value is within the allowed range
    if (( gas_value < 100 || gas_value > 20000 )); then
        echo "Error: Gas value must be between 100 and 20000."
        return 1
    fi

    return 0
}

# Ask for Alchemy API key
ALCHEMY_API_KEY=$(ask_for_input "Enter your Alchemy API key")

# Ask for wallet private key (visible input)
WALLET_PRIVATE_KEY=$(ask_for_input "Enter your wallet private key")

# Ask for gas value and validate it
while true; do
    GAS_VALUE=$(ask_for_input "Enter the gas value (must be an integer between 100 and 20000)")
    if validate_gas_value "$GAS_VALUE"; then
        break
    fi
done

# Ask if they want to enable EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API
read -p "Do you want to enable EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API? (y/n): " ENABLE_PENDING_ORDERS
if [[ "$ENABLE_PENDING_ORDERS" =~ ^[Yy]$ ]]; then
    EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API="true"
else
    EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API="false"
fi

# Ask if they want to enable EXECUTOR_PROCESS_ORDERS_API_ENABLED
read -p "Do you want to enable EXECUTOR_PROCESS_ORDERS_API_ENABLED? (y/n): " ENABLE_ORDERS_API
if [[ "$ENABLE_ORDERS_API" =~ ^[Yy]$ ]]; then
    EXECUTOR_PROCESS_ORDERS_API_ENABLED="true"
else
    EXECUTOR_PROCESS_ORDERS_API_ENABLED="false"
fi

# GENERAL SETTINGS
# Set Node Environment
export NODE_ENV=testnet

# Set log settings
export LOG_LEVEL=debug
export LOG_PRETTY=false

# Process bids, orders, and claims
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true

# Display the collected inputs and settings (for verification)
echo -e "\nCollected inputs and settings:"
echo "Alchemy API Key: $ALCHEMY_API_KEY"
echo "Wallet Private Key: $WALLET_PRIVATE_KEY"
echo "Gas Value: $GAS_VALUE"
echo "EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API: $EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API"
echo "EXECUTOR_PROCESS_ORDERS_API_ENABLED: $EXECUTOR_PROCESS_ORDERS_API_ENABLED"
echo "NODE_ENV: $NODE_ENV"
echo "LOG_LEVEL: $LOG_LEVEL"
echo "LOG_PRETTY: $LOG_PRETTY"
echo "EXECUTOR_PROCESS_BIDS_ENABLED: $EXECUTOR_PROCESS_BIDS_ENABLED"
echo "EXECUTOR_PROCESS_ORDERS_ENABLED: $EXECUTOR_PROCESS_ORDERS_ENABLED"
echo "EXECUTOR_PROCESS_CLAIMS_ENABLED: $EXECUTOR_PROCESS_CLAIMS_ENABLED"

# Step 5: Proceed with the installation or other setup steps
echo -e "\Running the node..."
./executor
