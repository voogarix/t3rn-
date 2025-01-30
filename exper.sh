#!/bin/bash
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${RED}Join our Telegram channel: https://t.me/kriptoqapik${NC}"
echo -e "${ORANGE}-----------------------------------------------------${NC}"
echo -e "${RED}Get free 20€ credit for VPS on Hetzner: https://hetzner.cloud/?ref=mjjaxNOJxUW1${NC}"
sleep 5

# Log file for debugging
	if ls setup.log 1> /dev/null 2>&1; then
        echo "Deleting previous setup.log file..."
        rm -f setup.log
    fi
	
LOG_FILE="setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to mask sensitive data in logs
mask_sensitive_data() {
    local data="$1"
    if [[ ${#data} -gt 12 ]]; then
        echo "${data:0:6}******${data: -6}"
    else
        echo "******"
    fi
}

# Function to display usage instructions
usage() {
    echo -e "${GREEN}Usage: $0 [--verbose] [--dry-run]${NC}"
    echo -e "${GREEN}  --verbose: Enable verbose logging for debugging.${NC}"
    echo -e "${GREEN}  --dry-run: Simulate script execution without making changes.${NC}"
    exit 0
}

# Parse command-line arguments
VERBOSE=false
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=true
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown argument: $arg${NC}"
            usage
            ;;
    esac
done

# Enable verbose mode if requested
if $VERBOSE; then
    set -x
fi

# Dry-run mode message
if $DRY_RUN; then
    echo -e "${ORANGE}Dry-run mode enabled. No changes will be made.${NC}"
fi

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
        echo -e "${RED}Error: Gas value must be an integer.${NC}"
        return 1
    fi

    # Check if the gas value is within the allowed range
    if (( gas_value < 100 || gas_value > 20000 )); then
        echo -e "${RED}Error: Gas value must be between 100 and 20000.${NC}"
        return 1
    fi

    return 0
}

# Step 0: Clean up previous installations
echo -e "${ORANGE}Cleaning up previous installations...${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would delete existing t3rn and executor directories.${NC}"
else
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
fi

# Step 1: Create and navigate to t3rn directory
echo -e "${ORANGE}Creating and navigating to t3rn directory...${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would create and navigate to t3rn directory.${NC}"
else
    mkdir -p t3rn
    cd t3rn || { echo -e "${RED}Failed to create or navigate to t3rn directory. Exiting.${NC}"; exit 1; }
fi

# Step 2: Download the latest release
echo -e "${ORANGE}Downloading the latest release...${NC}"
LATEST_TAG=$(curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}Failed to fetch the latest release tag. Please check your internet connection and try again.${NC}"
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
echo -e "${ORANGE}Extracting the archive...${NC}"
tar -xvzf "executor-linux-$LATEST_TAG.tar.gz"
if [ $? -ne 0 ]; then
    echo "Failed to extract the archive. Please check the file and try again."
    exit 1
fi
echo "Extraction complete."

# Step 4: Navigate to the executor binary location
echo -e "${ORANGE}Navigating to the executor binary location...${NC}"
if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would navigate to executor binary location.${NC}"
else
    mkdir -p executor/executor/bin
    cd executor/executor/bin || { echo -e "${RED}Failed to navigate to executor binary location. Exiting.${NC}"; exit 1; }
fi

# Ask if the user wants to run an API node or RPC node
while true; do
    read -p "Do you want to run an API node or RPC node? (api/rpc): " NODE_TYPE
    if [[ "$NODE_TYPE" == "api" || "$NODE_TYPE" == "rpc" ]]; then
        break
    else
        echo -e "${RED}Invalid input. Please enter 'api' or 'rpc'.${NC}"
    fi
done

# Ask for wallet private key (visible input)
WALLET_PRIVATE_KEY=$(ask_for_input "Enter your wallet private key")
MASKED_PRIVATE_KEY=$(mask_sensitive_data "$WALLET_PRIVATE_KEY")

# Ask for gas value and validate it
while true; do
    GAS_VALUE=$(ask_for_input "Enter the gas value (must be an integer between 100 and 20000)")
    if validate_gas_value "$GAS_VALUE"; then
        break
    fi
done

# Set Node Environment
export NODE_ENV=testnet
export PRIVATE_KEY_LOCAL=$WALLET_PRIVATE_KEY

# Set log settings
export LOG_LEVEL=debug
export LOG_PRETTY=false

# Process bids, orders, and claims
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true

# Configure API-specific settings based on node type
if [[ "$NODE_TYPE" == "api" ]]; then
    # Automatically enable API-related settings for API nodes
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=true
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED=true
else
    # Automatically disable API-related settings for RPC nodes
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
    export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
fi

# Default RPC endpoints
DEFAULT_RPC_ENDPOINTS_ARBT="https://arbitrum-sepolia-rpc.publicnode.com"
DEFAULT_RPC_ENDPOINTS_BSSP="https://sepolia.base.org"
DEFAULT_RPC_ENDPOINTS_BLSS="https://sepolia.blast.io"
DEFAULT_RPC_ENDPOINTS_OPSP="https://sepolia.optimism.io"
DEFAULT_RPC_ENDPOINTS_L1RN="https://brn.calderarpc.com/http,https://brn.rpc.caldera.xyz/"

# Ask if the user wants to add custom RPC endpoints or use default ones
read -p "Do you want to add custom public RPC endpoints? (y/n): " CUSTOM_RPC
if [[ "$CUSTOM_RPC" =~ ^[Yy]$ ]]; then
    echo "Enter custom RPC endpoints (comma-separated for multiple endpoints):"
    RPC_ENDPOINTS_ARBT=$(ask_for_input "Arbitrum Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_ARBT)")
    RPC_ENDPOINTS_BSSP=$(ask_for_input "Base Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BSSP)")
    RPC_ENDPOINTS_BLSS=$(ask_for_input "Blast Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_BLSS)")
    RPC_ENDPOINTS_OPSP=$(ask_for_input "Optimism Sepolia RPC endpoints (default: $DEFAULT_RPC_ENDPOINTS_OPSP)")

    # Use default values if the user leaves the input blank
    RPC_ENDPOINTS_ARBT=${RPC_ENDPOINTS_ARBT:-$DEFAULT_RPC_ENDPOINTS_ARBT}
    RPC_ENDPOINTS_BSSP=${RPC_ENDPOINTS_BSSP:-$DEFAULT_RPC_ENDPOINTS_BSSP}
    RPC_ENDPOINTS_BLSS=${RPC_ENDPOINTS_BLSS:-$DEFAULT_RPC_ENDPOINTS_BLSS}
    RPC_ENDPOINTS_OPSP=${RPC_ENDPOINTS_OPSP:-$DEFAULT_RPC_ENDPOINTS_OPSP}
else
    # Use default RPC endpoints
    RPC_ENDPOINTS_ARBT=$DEFAULT_RPC_ENDPOINTS_ARBT
    RPC_ENDPOINTS_BSSP=$DEFAULT_RPC_ENDPOINTS_BSSP
    RPC_ENDPOINTS_BLSS=$DEFAULT_RPC_ENDPOINTS_BLSS
    RPC_ENDPOINTS_OPSP=$DEFAULT_RPC_ENDPOINTS_OPSP
fi

# Function to rotate L1RN RPCs
rotate_l1rn_rpcs() {
    local rpcs=(${RPC_ENDPOINTS_L1RN//,/ })
    if [[ ${#rpcs[@]} -gt 1 ]]; then
        RPC_ENDPOINTS_L1RN=$(IFS=,; echo "${rpcs[*]:1} ${rpcs[0]}" | tr ' ' ',')
        echo -e "${ORANGE}Rotated L1RN RPCs to: $RPC_ENDPOINTS_L1RN${NC}"
    else
        echo -e "${ORANGE}Not enough RPCs to rotate.${NC}"
    fi
}

# Ask if the user wants to rotate L1RN RPCs
read -p "Do you want to rotate L1RN RPCs? (y/n): " ROTATE_RPC
if [[ "$ROTATE_RPC" =~ ^[Yy]$ ]]; then
    rotate_l1rn_rpcs
fi

# Ask user which networks to enable
echo "Available networks:"
echo "ARBT = arbitrum-sepolia"
echo "BSSP = base-sepolia"
echo "OPSP = optimism-sepolia"
echo "BLSS = blast-sepolia"
echo "L1RN is always enabled."

ENABLED_NETWORKS="l1rn"
while true; do
    read -p "Enter the networks you want to enable (comma-separated, e.g., ARBT,BSSP,OPSP,BLSS or press Enter/type 'all' to enable all): " USER_NETWORKS
    if [[ -z "$USER_NETWORKS" || "$USER_NETWORKS" =~ ^[Aa][Ll][Ll]$ ]]; then
        ENABLED_NETWORKS="$ENABLED_NETWORKS,arbitrum-sepolia,base-sepolia,optimism-sepolia,blast-sepolia"
        break
    else
        IFS=',' read -r -a networks <<< "$USER_NETWORKS"
        valid=true
        for network in "${networks[@]}"; do
            case "$network" in
                ARBT)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,arbitrum-sepolia"
                    ;;
                BSSP)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,base-sepolia"
                    ;;
                OPSP)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,optimism-sepolia"
                    ;;
                BLSS)
                    ENABLED_NETWORKS="$ENABLED_NETWORKS,blast-sepolia"
                    ;;
                *)
                    echo -e "${RED}Invalid network: $network. Please enter valid networks.${NC}"
                    valid=false
                    break
                    ;;
            esac
        done
        if $valid; then
            break
        fi
    fi
done

# Export RPC endpoints
export RPC_ENDPOINTS_ARBT
export RPC_ENDPOINTS_BSSP
export RPC_ENDPOINTS_BLSS
export RPC_ENDPOINTS_OPSP
export RPC_ENDPOINTS_L1RN
export EXECUTOR_MAX_L3_GAS_PRICE=$GAS_VALUE
export ENABLED_NETWORKS
export 

# Display the collected inputs and settings (for verification)
echo -e "\nCollected inputs and settings:"
echo "Node Type: $NODE_TYPE"
if [[ "$NODE_TYPE" == "rpc" ]]; then
    # Mask the API key for display
    ALCHEMY_API_KEY=$(ask_for_input "Enter your Alchemy API key")
    MASKED_API_KEY=$(mask_sensitive_data "$ALCHEMY_API_KEY")
    echo "Alchemy API Key: $MASKED_API_KEY"
fi

# Mask the private key for display
echo "Wallet Private Key: $MASKED_PRIVATE_KEY"

echo "Gas Value: $GAS_VALUE"
echo "EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API: $EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API"
echo "EXECUTOR_PROCESS_ORDERS_API_ENABLED: $EXECUTOR_PROCESS_ORDERS_API_ENABLED"
echo "NODE_ENV: $NODE_ENV"
echo "LOG_LEVEL: $LOG_LEVEL"
echo "LOG_PRETTY: $LOG_PRETTY"
echo "EXECUTOR_PROCESS_BIDS_ENABLED: $EXECUTOR_PROCESS_BIDS_ENABLED"
echo "EXECUTOR_PROCESS_ORDERS_ENABLED: $EXECUTOR_PROCESS_ORDERS_ENABLED"
echo "EXECUTOR_PROCESS_CLAIMS_ENABLED: $EXECUTOR_PROCESS_CLAIMS_ENABLED"
echo "RPC Endpoints:"
echo "ARBT: $RPC_ENDPOINTS_ARBT"
echo "BSSP: $RPC_ENDPOINTS_BSSP"
echo "BLSS: $RPC_ENDPOINTS_BLSS"
echo "OPSP: $RPC_ENDPOINTS_OPSP"
echo "L1RN: $RPC_ENDPOINTS_L1RN"
echo "Enabled Networks: $ENABLED_NETWORKS"

# Step 5: Proceed with the installation or other setup steps
echo -e "\nIf this script helped you, don't forget to give a ⭐ on GitHub 😉..."
sleep 5

if $DRY_RUN; then
    echo -e "${GREEN}[Dry-run] Would run the node.${NC}"
else
    echo -e "${ORANGE}Running the node...${NC}"
    ./executor
fi
